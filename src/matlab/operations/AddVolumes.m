function [status, result] = AddVolumes(pathToWorkspace, ...
                                       params, ...
                                       config)
%ADDVOLUMES Add two volumes.
%   Uses `fslmaths` with `add` to add two volumes.
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
  params.inputVolume1 char
  params.inputVolume2 char
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

command = 'fslmaths %s -add %s %s';
sentence = sprintf(command, fullInputVolume1, fullInputVolume2, fullOutputVolume);
[status, result] = CallSystem(sentence, verbose);

end
