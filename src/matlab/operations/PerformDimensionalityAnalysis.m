function [status, result] = PerformDimensionalityAnalysis(pathToWorkspace, ...
                                                          params, ...
                                                          config)
%PERFORMDIMENSIONALITYANALYSIS Summary of this function goes here
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
  % filename for input
  params.brainVolume char
  % use supplied mask image for calculating metric
  params.maskVolume char
  % path for output
  params.outputFile char
  config.regressorsOutputFile char
  config.numPcaComponents double {mustBeInteger} = 5
  config.verbose logical = false
end

status = 0;

brain = MRIread(fullfile(pathToWorkspace, params.brainVolume));
[~, ~, ~, numTimePoints] = size(brain.vol);

[mask, numVoxels] = GetMask(fullfile(pathToWorkspace, params.maskVolume), ...
                            numTimePoints);

numPcaComponents = config.numPcaComponents;

outputFile = fullfile(pathToWorkspace, params.outputFile);
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
