function [status, result] = SubtractVolume(pathToWorkspace, config)
%SUBTRACTVOLUME Subtract an input volume from another.
%   Uses `fslmaths` with `sub` to subtract the second input volume from the
%   first input volume.
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
  % minuend volume
  config.inputVolume1 char
  % subtrahend volume
  config.inputVolume2 char
  % difference volume
  config.outputVolume char
  % switch on diagnostic messages
  config.verbose logical = false
  config.v logical = false
end

% normalize if multiple options mean the same thing
verbose = config.verbose || config.v;

fullInputVolume1 = fullfile(pathToWorkspace, config.inputVolume1);
fullInputVolume2 = fullfile(pathToWorkspace, config.inputVolume2);
fullOutputVolume = fullfile(pathToWorkspace, config.outputVolume);

command = 'fslmaths %s -sub %s %s';
sentence = sprintf(command, fullInputVolume1, fullInputVolume2, fullOutputVolume);
[status, result] = CallSystem(sentence, verbose);

end
