function [status, result] = SubtractVolume(pathToWorkspace, ...
                                           params, ...
                                           config)
%SUBTRACTVOLUME Subtract an input volume from another.
%   Uses `fslmaths` with `sub` to subtract the second input volume from the
%   first input volume.
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
  % minuend volume
  params.inputVolume1 char
  % subtrahend volume
  params.inputVolume2 char
  % difference volume
  params.outputVolume char
  % switch on diagnostic messages
  config.verbose logical = false
  config.v logical = false
end

% normalize if multiple options mean the same thing
verbose = config.verbose || config.v;

fullInputVolume1 = fullfile(pathToWorkspace, params.inputVolume1);
fullInputVolume2 = fullfile(pathToWorkspace, params.inputVolume2);
fullOutputVolume = fullfile(pathToWorkspace, params.outputVolume);

command = 'fslmaths %s -sub %s %s';
sentence = sprintf(command, fullInputVolume1, fullInputVolume2, fullOutputVolume);
[status, result] = CallSystem(sentence, verbose);

end
