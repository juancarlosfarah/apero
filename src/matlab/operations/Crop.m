function [status, result] = Crop(pathToWorkspace, config)
%CROP Crop FOV of volume to remove lower head and neck.
%   Uses `robustfov` to remove lower head and neck.
%
%
%   Input:
%   - pathToWorkspace:  Path to the workspace.
%   - config:           Configuration to be used in the operation.
%
%   Output:
%   - status:  Status returned by system call.
%   - result:  Result returned by system call.
%
% TODO:
%   -b      size of brain in z-dimension (default 170mm)
%   -r      ROI volume output name
%   --debug turn on debugging output

arguments
  pathToWorkspace char = '.'
  config.inputVolume char
  config.outputVolume char
  % transformation matrix is written to this file
  config.m char
  % switch on diagnostic messages
  config.verbose logical = false
  config.v logical = false
end

% normalize if multiple options mean the same thing
verbose = config.verbose || config.v;

fullInputVolume = fullfile(pathToWorkspace, config.inputVolume);

command = 'robustfov -i %s';
command = sprintf(command, fullInputVolume);

% transformation matrix is written to this file
if isfield(config, 'm')
  command = sprintf('%s -m %s', command, config.m);
end

if isfield(config, 'outputVolume')
  fullOutputVolume = fullfile(pathToWorkspace, config.outputVolume);
  command = sprintf('%s -r %s', command, fullOutputVolume);
end

[status, result] = CallSystem(command, verbose);

end
