function [status, result] = FillHoles(pathToWorkspace, ...
                                      params, ...
                                      config)
%FILLHOLES Fill holes in the volume, without changing fov.
%   Uses `fslmaths` with `fillh` to fill holes in a volume.
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
  config.verbose logical = false
end

fullInputVolume = fullfile(pathToWorkspace, params.inputVolume);
fullOutputVolume = fullfile(pathToWorkspace, params.outputVolume);
command = 'fslmaths %s -fillh %s';
sentence = sprintf(command, fullInputVolume, fullOutputVolume);

[status, result] = CallSystem(sentence, config.verbose);

end

