function [status, result] = ReorientToStandard(pathToWorkspace, ...
                                               params, ...
                                               config)
%REORIENTTOSTANDARD Add two volumes.
%   Uses `fslreorient2std` to reorient a volume.
%
%   Reorients the image to match the approximate orientation of the
%   standard template images.
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
  % transformation matrix is written to this file
  config.m char
  % switch on diagnostic messages
  config.verbose logical = false
  config.v logical = false
end

% normalize if multiple options mean the same thing
verbose = config.verbose || config.v;

fullInputVolume = fullfile(pathToWorkspace, params.inputVolume);

command = 'fslreorient2std %s';
command = sprintf(command, fullInputVolume);

% transformation matrix is written to this file
if isfield(config, 'm')
  command = sprintf('%s -m %s', command, config.m);
end

if isfield(params, 'outputVolume')
  fullOutputVolume = fullfile(pathToWorkspace, params.outputVolume);
  command = sprintf('%s %s', command, fullOutputVolume);
end

[status, result] = CallSystem(command, verbose);

end