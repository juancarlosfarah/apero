function [status, result] = CorrectSliceTiming(pathToWorkspace, ...
                                               params, ...
                                               config)
%CORRECTSLICETIMING Corrects slice timing.
%   Uses `slicetimer` to correct a timeseries.
%
%   Corrects slice timing.
%
%   Input:
%   - pathToWorkspace:  Path to the workspace.
%   - params:           Parameters to be used in the operation.
%   - config:           Configuration to be used in the operation.
%
%   Output:
%   - status:  Status returned by system call.
%   - result:  Result returned by system call.
%
% TODO:
% 	--tcustom	filename of single-column slice timings, in fractions of TR, +ve values shift slices forwards in time.
% 	--tglobal	global shift in fraction of TR, (default is 0)

arguments
  pathToWorkspace char = '.'
  params.inputVolume char
  params.outputVolume char
  % use interleaved acquisition
  config.odd logical = false
  % reverse slice indexing
  config.down logical = false
  % temporal resolution
  config.r double = 3
  % direction of slice acquisition (x=1, y=2, z=3)
  config.d double {mustBeInteger, mustBeInRange(config.d, 1, 3)} = 3
  % filename of single-column custom interleave order file
  % (first slice is referred to as 1 not 0)
  config.ocustom char
  % switch on diagnostic messages
  config.verbose logical = false
  config.v logical = false
end

% normalize if multiple options mean the same thing
verbose = config.verbose || config.v;

fullInputVolume = fullfile(pathToWorkspace, params.inputVolume);

command = 'slicetimer -i %s';
command = sprintf(command, fullInputVolume);

if isfield(params, 'outputVolume')
  fullOutputVolume = fullfile(pathToWorkspace, params.outputVolume);
  command = sprintf('%s -o %s', command, fullOutputVolume);
end

% temporal resolution
command = sprintf('%s -r %0.4f', command, config.r);

% direction of slice acquisition
command = sprintf('%s -d %d', command, config.d);

% use interleaved acquisition
if config.odd
  command = sprintf('%s --odd', command);
end

% reverse slice indexing
if config.down
  command = sprintf('%s --down', command);
end

% filename of single-column custom interleave order file
if isfield(config, 'ocustom')
  command = sprintf('%s --ocustom %s', command, config.ocustom);
end

[status, result] = CallSystem(command, verbose);

end