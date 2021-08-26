function [status, result] = ComputeMeanVolume(pathToWorkspace, ...
                                              params, ...
                                              config)
%COMPUTEMEANVOLUME Computes mean volume across the time dimension.
%   Uses `fslmaths` with `-Tmean` to collapse the time dimension.
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
  % switch on diagnostic messages
  config.verbose logical = false
  config.v logical = false
end

% normalize if multiple options mean the same thing
verbose = config.verbose || config.v;

fullInputVolume = fullfile(pathToWorkspace, params.inputVolume);
fullOutputVolume = fullfile(pathToWorkspace, params.outputVolume);

command = 'fslmaths %s -Tmean %s';
command = sprintf(command, fullInputVolume, fullOutputVolume);

[status, result] = CallSystem(command, verbose);

end
