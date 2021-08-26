% function [mask, ts, var, pca, avg, deriv, numVoxels] = 
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
  config.numPcaComponents int8 = 5
  config.verbose logical = false
end

status = 0;

mask = MRIread(fullfile(pathToWorkspace, params.maskVolume));
brain = MRIread(fullfile(pathToWorkspace, params.brainVolume));

[~, ~, ~, numTimePoints] = size(brain.vol);
numPcaComponents = config.numPcaComponents;

outputFile = fullfile(pathToWorkspace, params.outputFile);


numVoxels = nnz(mask.vol);
mask = logical(repmat(mask.vol, [1, 1, 1, numTimePoints]));
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
   
result = 'PerformDimensionalityAnalysis: saved result of analysis';
if config.verbose
  fprintf('%s\n', result);
end

end
