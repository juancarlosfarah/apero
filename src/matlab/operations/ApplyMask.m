function [status, result] = ApplyMask(pathToWorkspace, ...
                                      params, ...
                                      config)
%APPLYMASK Apply a mask to an image.
%   Uses `fslmaths` to apply a mask to an image.
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
  % filename of input image (to be masked)
  params.inputVolume char
  % filename for output (masked) image
  params.outputVolume char
  % filename for mask
  params.maskVolume char
  % optional
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
fullInputVolume = fullfile(pathToWorkspace, params.inputVolume);
fullMaskVolume = fullfile(pathToWorkspace, params.maskVolume);
fullOutputVolume = fullfile(pathToWorkspace, params.outputVolume);


command = 'fslmaths %s -mas %s %s';
sentence = sprintf(command, fullInputVolume, fullMaskVolume, fullOutputVolume);
[status, result] = CallSystem(sentence, verbose);

end
