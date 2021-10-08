function [status, result] = NormalizeIntensity(pathToWorkspace, config)
%NORMALIZEINTENSITY Normalize intensity.
%   Uses `fslmaths` with `-ing` to normalize intensity.
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
  config.meanIntensity double = 1000
  % switch on diagnostic messages
  config.verbose logical = false
end

% normalize if multiple options mean the same thing
verbose = config.verbose;

fullInputVolume = fullfile(pathToWorkspace, config.inputVolume);
fullOutputVolume = fullfile(pathToWorkspace, config.outputVolume);
command = 'fslmaths %s -ing %d %s';
sentence = sprintf(command, ...
                   fullInputVolume, ...
                   config.meanIntensity, ...
                   fullOutputVolume);
                 
[status, result] = CallSystem(sentence, verbose);

end

