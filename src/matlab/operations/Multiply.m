function [status, result] = Multiply(pathToWorkspace, config)
%MULTIPLY Multiply a volume by a factor.
%   Uses `fslmaths` with `mul` to multiply a volume by a factor.
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
  config.outputVolume char
  % factor to multiply by
  config.factor double
  % switch on diagnostic messages
  config.verbose logical = false
  config.v logical = false
end

% normalize if multiple options mean the same thing
verbose = config.verbose || config.v;

fullInputVolume = fullfile(pathToWorkspace, config.inputVolume);
fullOutputVolume = fullfile(pathToWorkspace, config.outputVolume);

command = 'fslmaths %s -mul %d %s';
sentence = sprintf(command, fullInputVolume, config.factor, fullOutputVolume);
[status, result] = CallSystem(sentence, verbose);

end
