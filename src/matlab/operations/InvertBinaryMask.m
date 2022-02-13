function [status, result, command] = InvertBinaryMask(pathToWorkspace, config)
%INVERTBINARYMASK Invert a binary mask.
%   Uses `fslmaths` to invert a binary mask.
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
  % optional step
  config.optional logical = false
  % clobber previous output
  config.clobber logical = false
  % switch on diagnostic messages
  config.verbose logical = false
  config.v logical = false
end

% normalize if multiple options mean the same thing
verbose = config.verbose || config.v;

%% main command
fullInputVolume = fullfile(pathToWorkspace, config.inputVolume);
fullOutputVolume = fullfile(pathToWorkspace, config.outputVolume);
command = 'fslmaths %s -mul -1 -add 1 %s';
command = sprintf(command, fullInputVolume, fullOutputVolume);

[status, result] = CallSystem(command, verbose);

end

