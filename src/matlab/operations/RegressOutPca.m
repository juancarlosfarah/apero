function [status, result] = RegressOutPca(pathToWorkspace, ...
                                          params, ...
                                          config)
%REGRESSOUTPCA Summary of this function goes here
%   Detailed explanation goes here
%
%   Input:
%   - pathToWorkspace:  Path to the workspace.
%   - params:           Parameters to be used in the operation.
%   - config:           Configuration to be used in the operation.
%
%   Output:
%   - status:  Status returned by system call.
%   - result:  Result returned by system call.

arguments
  pathToWorkspace char = '.'
  params.brainVolume char
  params.maskVolume char
  params.outputVolume char
  config.numComponents double {mustBeInteger} = 5
  config.pcaFiles cell = {}
  % switch on diagnostic messages
  config.verbose logical = false
end

% succeed by default
status = 0;

pcaFiles = config.pcaFiles;
brainVolume = MRIread(fullfile(pathToWorkspace, params.brainVolume));
maskVolume = MRIread(fullfile(pathToWorkspace, params.maskVolume));

% count number of time points
[~, ~, ~, numTimePoints] = size(brainVolume.vol);

[mask, ~] = Generate4dMask(fullfile(pathToWorkspace, params.maskVolume), ...
                           numTimePoints);

% set voxels outside the brain to 0
brainVolume.vol(~mask) = 0;

% prepare pca regressors
regressors = [];
for i = 1 : length(pcaFiles)
  pcaFile = pcaFiles{i};
  pcaFileObj = matfile(fullfile(pathToWorkspace, pcaFile));
  % for this regression we only consider variables called `pca`
  pcaVar = pcaFileObj.pca;
  % suppress warning of growing array
  regressors{end + 1} = pcaVar(:, 1 : config.numComponents); %#ok<AGROW>
end

% add slope of the regression at the end
regressors{end + 1} = ones(numTimePoints, 1);

% merge regressors
regressors = cat(2, regressors{:});

%% regress out normalized regressors
brainVolume.vol = ApplyRegressors(brainVolume.vol, ...
                                  maskVolume.vol, ...
                                  regressors);

outputVolume = fullfile(pathToWorkspace, params.outputVolume);

% write brain volume with regressors applied
err = MRIwrite(brainVolume, outputVolume, 'double');

if err
  % todo: throw error
  status = 1;
  result = 'RegressOutPca: error writing brain volume';
  fprintf('%s\n', result);
  return
end
                                
result = 'RegressOutPca: saved result of regression';
if config.verbose
  fprintf('%s\n', result);
end


end

