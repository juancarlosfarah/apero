function [status, result] = Detrend(pathToWorkspace, config)
%DETREND Summary of this function goes here
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
  config.inputVolume char
  config.maskVolume char
  config.outputVolume char
  % switch on diagnostic messages
  config.verbose logical = false
end

% success by default
status = 0;

inputVolume = fullfile(pathToWorkspace, config.inputVolume);
maskVolume = fullfile(pathToWorkspace, config.maskVolume);
outputVolume = fullfile(pathToWorkspace, config.outputVolume);
verbose = config.verbose;

%% read data
resting = MRIread(inputVolume);
[sizeX, sizeY, sizeZ, numTimePoints] = size(resting.vol);

%% read brain mask
volBrain = MRIread(maskVolume);

for i = 1 : sizeX
  for j = 1 : sizeY
    for k = 1 : sizeZ
      if volBrain.vol(i, j, k) > 0
        tsVoxel = reshape(resting.vol(i, j, k, :), [numTimePoints, 1]);
        % linear vs quadratic
        tsVoxelDetrended = detrend(tsVoxel - mean(tsVoxel), 'linear');
        resting.vol(i, j, k, :) = tsVoxelDetrended;
      end
    end
  end
  % display progress if verbose
  if verbose
    if (mod(i, 25) == 0)
      disp(i / sizeX)
    end
  end
end

err = MRIwrite(resting, outputVolume, 'double');

if err
  % todo: throw error
  status = 1;
  result = 'Detrend: error writing detrended volume';
  fprintf('%s\n', result);
  return
else
  result = 'Detrend: detrended volume successfully';
end

end

