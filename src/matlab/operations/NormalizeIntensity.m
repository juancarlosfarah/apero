function [status, result] = NormalizeIntensity(pathToWorkspace, ...
                                               params, ...
                                               config)
%NORMALIZEINTENSITY Normalize intensity.
%   Uses `fslmaths` with `-ing` to normalize intensity.
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
  params.inputVolume char
  params.outputVolume char
  config.meanIntensity double = 1000
  % switch on diagnostic messages
  config.verbose logical = false
end

% normalize if multiple options mean the same thing
verbose = config.verbose;

fullInputVolume = fullfile(pathToWorkspace, params.inputVolume);
fullOutputVolume = fullfile(pathToWorkspace, params.outputVolume);
command = 'fslmaths %s -ing %d %s';
sentence = sprintf(command, ...
                   fullInputVolume, ...
                   config.meanIntensity, ...
                   fullOutputVolume);
                 
[status, result] = CallSystem(sentence, verbose);

end

