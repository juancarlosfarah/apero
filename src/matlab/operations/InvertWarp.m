function [status, result] = InvertWarp(pathToWorkspace, ...
                                       params, ...
                                       config)
%INVERTWARP Invert a non-linear mapping.
%   Uses `invwarp` to invert a non-linear mapping.
%
%   Input:
%   - pathToWorkspace:  Path to the workspace.
%   - params:           Parameters to be used in the operation.
%   - config:           Configuration to be used in the operation.
%
%   Output:
%   - status:  Status returned by system call.
%   - result:  Result returned by system call.
%
% Optional arguments (You may optionally specify one or more of):
% 	--rel	use relative warp convention: x' = x + w(x)
% 	--abs	use absolute warp convention (default): x' = w(x)
% 	--noconstraint	do not apply the Jacobian constraint
% 	--jmin	minimum acceptable Jacobian value for constraint (default 0.01)
% 	--jmax	maximum acceptable Jacobian value for constraint (default 100.0)

arguments
  pathToWorkspace char = '.'
  % filename for warp/shiftmap transform (volume)
  params.warpVolume char
  % filename for output (inverse warped) image
  params.outputVolume char
  % filename for new reference image, i.e., what was originally the input image
  % (determines inverse warpvol's FOV and pixdims)
  params.referenceVolume char
  % turn on debugging output
  config.debug logical = false
  config.d logical = false
  % switch on diagnostic messages
  config.verbose logical = false
  config.v logical = false
end

fullWarpVolume = fullfile(pathToWorkspace, params.warpVolume);
fullReferenceVolume = fullfile(pathToWorkspace, params.referenceVolume);
fullOutputVolume = fullfile(pathToWorkspace, params.outputVolume);

command = 'invwarp --warp=%s --ref=%s --out=%s';
command = sprintf(command, ...
                  fullWarpVolume, ...
                  fullReferenceVolume, ...
                  fullOutputVolume);

% turn on debugging output
if config.debug || config.d
  command = sprintf('%s --debug', command);
end

% verbose (switch on diagnostic messages)
if config.verbose || config.v
  command = sprintf('%s -v', command);
end
                 
[status, result] = CallSystem(command, config.verbose);

end
