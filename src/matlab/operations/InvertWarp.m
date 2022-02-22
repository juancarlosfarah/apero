function [status, result] = InvertWarp(pathToWorkspace, config)
%INVERTWARP Invert a non-linear mapping.
%   Uses `invwarp` to invert a non-linear mapping.
%
%   Input:
%   - pathToWorkspace:  Path to the workspace.
%   - config:           Configuration to be used in the operation.
%
%   Output:
%   - status:  Status returned by system call.
%   - result:  Result returned by system call.
%
% todo:
% Optional arguments (You may optionally specify one or more of):
% 	--noconstraint	do not apply the Jacobian constraint

arguments
  pathToWorkspace char = '.'
  % filename for warp/shiftmap transform (volume)
  config.warpVolume char
  % filename for output (inverse warped) image
  config.outputVolume char
  % filename for new reference image, i.e., what was originally the input image
  % (determines inverse warpvol's FOV and pixdims)
  config.referenceVolume char
  % choose either absolute x' = w(x) (default)
  % or relative x' = x + w(x) for warp convention
  config.abs logical = true
  config.rel logical = false
  % turn on debugging output
  config.debug logical = false
  config.d logical = false
  % minimum acceptable Jacobian value for constraint (default 0.01)
  config.jmin double = 0.01
  % maximum acceptable Jacobian value for constraint (default 100.0)
  config.jmax double = 100.0
  % switch on diagnostic messages
  config.verbose logical = false
  config.v logical = false
end

fullWarpVolume = fullfile(pathToWorkspace, config.warpVolume);
fullReferenceVolume = fullfile(pathToWorkspace, config.referenceVolume);
fullOutputVolume = fullfile(pathToWorkspace, config.outputVolume);

command = 'invwarp --warp=%s --ref=%s --out=%s';
command = sprintf(command, ...
                  fullWarpVolume, ...
                  fullReferenceVolume, ...
                  fullOutputVolume);

% use absolute warp convention (default): x' = w(x)
% use relative warp convention: x' = x + w(x)
if config.rel
  command = sprintf('%s --rel', command);
  if config.abs
    warning('InvertWarp: Both --abs and --rel flags are set! Defaulting to using --rel.');
  end
else
  command = sprintf('%s --abs', command);
end

% minimum acceptable Jacobian value for constraint (default 0.01)
command = sprintf('%s --jmin=%0.4f', command, config.jmin);

% maximum acceptable Jacobian value for constraint (default 100.0)
command = sprintf('%s --jmax=%0.4f', command, config.jmax);

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
