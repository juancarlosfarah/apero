function [status, result] = PerformDimensionalityAnalysis(pathToWorkspace, ...
                                                          config)
%PERFORMDIMENSIONALITYANALYSIS Summary of this function goes here
%   Detailed explanation goes here
%
%   Input:
%   - pathToWorkspace:  Path to the workspace.
%   - config:           Configuration to be used in the operation.
%
%   Output:
%   - status:  Status returned by system call.
%   - result:  Result returned by system call.

arguments
  pathToWorkspace char = '.'
  % filename for input
  config.brainVolume char
  % use supplied mask image for calculating metric
  config.maskVolume char
  % path for output
  config.outputFile char
  config.regressorsOutputFile char
  config.numPcaComponents double {mustBeInteger} = 5
  config.verbose logical = false
end

status = 0;

brain = MRIread(fullfile(pathToWorkspace, config.brainVolume));
[~, ~, ~, numTimePoints] = size(brain.vol);

[mask, numVoxels] = Generate4dMask(fullfile(pathToWorkspace, config.maskVolume), ...
                                   numTimePoints);

numPcaComponents = config.numPcaComponents;

outputFile = fullfile(pathToWorkspace, config.outputFile);
regressorsOutputFile = fullfile(pathToWorkspace, ...
                                config.regressorsOutputFile);

% time series of voxels
ts = reshape(brain.vol(mask), [numVoxels, numTimePoints]);
[pca, var] = GetPca(ts', numPcaComponents);
avg = mean(ts);
deriv = [0, diff(avg)];
save(outputFile, ...
     'mask', ...
     'ts', ...
     'var', ...
     'pca', ...
     'avg', ...
     'deriv', ...
     'numVoxels');

% regressors are transformed
avgRegressor = avg';
derivRegressors = deriv';
% save in a format that can be used automatically by PerformRegression
save(regressorsOutputFile, ...
     'avgRegressor', ...
     'derivRegressors');
   
result = 'PerformDimensionalityAnalysis: saved result of analysis';
if config.verbose
  fprintf('%s\n', result);
end

end
