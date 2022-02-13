function [status, result, command] = BinarizeInvert(pathToWorkspace, config)
%BINARIZEINVERT Binarize and invert an image.
%   Uses `fslmaths` to binarize and invert an image.
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
  % filename of input image
  config.inputVolume char
  % filename of output image
  config.outputVolume char
  % switch on diagnostic messages
  config.verbose logical = false
  config.v logical = false
end

% normalize if multiple options mean the same thing
verbose = config.verbose || config.v;

%% main command
fullInputVolume = fullfile(pathToWorkspace, config.inputVolume);
fullOutputVolume = fullfile(pathToWorkspace, config.outputVolume);
command = 'fslmaths %s -binv %s';
command = sprintf(command, fullInputVolume, fullOutputVolume);

[status, result] = CallSystem(command, verbose);

end

