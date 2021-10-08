function [status, result] = FillHoles(pathToWorkspace, config)
%FILLHOLES Fill holes in the volume, without changing fov.
%   Uses `fslmaths` with `fillh` to fill holes in a volume.
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
  config.verbose logical = false
end

fullInputVolume = fullfile(pathToWorkspace, config.inputVolume);
fullOutputVolume = fullfile(pathToWorkspace, config.outputVolume);
command = 'fslmaths %s -fillh %s';
sentence = sprintf(command, fullInputVolume, fullOutputVolume);

[status, result] = CallSystem(sentence, config.verbose);

end

