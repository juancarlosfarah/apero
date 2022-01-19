function [status, result, sentence] = AddVolumes(pathToWorkspace, config)
%ADDVOLUMES Add two volumes.
%   Uses `fslmaths` with `add` to add two volumes.
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
  config.inputVolume1 char
  config.inputVolume2 char
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

command = 'fslmaths %s -add %s %s';
sentence = sprintf(command, fullInputVolume1, fullInputVolume2, fullOutputVolume);
[status, result] = CallSystem(sentence, verbose);

end
