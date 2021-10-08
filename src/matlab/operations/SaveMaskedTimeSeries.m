function [status, result] = SaveMaskedTimeSeries(pathToWorkspace, config)
%SAVEMASKEDTIMESERIES Summary of this function goes here
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
  % use supplied mask image to calculate residuals
  config.maskVolume char
  % path for output
  config.outputFile char
  config.verbose logical = false
end

status = 0;

brain = MRIread(fullfile(pathToWorkspace, config.brainVolume));
[~, ~, ~, numTimePoints] = size(brain.vol);

[mask, numVoxels] = Generate4dMask(fullfile(pathToWorkspace, config.maskVolume), ...
                                   numTimePoints);

ts = reshape(brain.vol(mask), [numVoxels, numTimePoints]);

outputFile = fullfile(pathToWorkspace, config.outputFile);

% save variables to file
save(outputFile, 'ts', 'mask');

result = 'SaveMaskedTimeSeries: saved masked time series';
if config.verbose
  fprintf('%s\n', result);
end

end
