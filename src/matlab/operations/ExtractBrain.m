function [status, result, command] = ExtractBrain(pathToWorkspace, config)
%EXTRACTBRAIN Summary of this function goes here
%   Extracts brain from fMRI data using FSL's `bet`.
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
  % variations on default bet2 functionality (mutually exclusive options):
  config.type char {mustBeMember(config.type, { ...
    '', ...  % just run bet2
    'R', ... % robust brain centre estimation (iterates BET several times)
    'S', ... % eye & optic nerve cleanup (can be useful in SIENA - disables -o option)
    'B', ... % bias field & neck cleanup (can be useful in SIENA)    
    'Z', ... % improve BET if FOV is very small in Z (by temporarily padding end slices)
    'F', ... % apply to 4D FMRI data (uses -f 0.3 and dilates brain mask slightly)
    'A'      % run bet2 and then betsurf to get additional skull and scalp surfaces (includes registrations)
  })} = ''
  % generate brain surface outline overlaid onto original image
  config.o logical = false
  % generate binary brain mask
  config.m logical = false
  % generate approximate skull image
  config.s logical = false
  % don't generate segmented brain image output
  config.n logical = false
  % fractional intensity threshold (0->1); default=0.5;
  % smaller values give larger brain outline estimates
  config.f double {mustBeInRange(config.f, 0, 1)} = 0.5
  % vertical gradient in fractional intensity threshold (-1->1); default=0;
  % positive values give larger brain outline at bottom, smaller at top
  config.g double {mustBeInRange(config.g, -1, 1)} = 0
  % apply thresholding to segmented brain image and mask
  config.t logical = false
  % generates brain surface as mesh in .vtk format
  config.e logical = false
  % debug (don't delete temporary intermediate images)
  config.debug logical = false
  config.d logical = false
  % verbose (switch on diagnostic messages)
  config.verbose logical = false
  config.v logical = false
end

% normalize if multiple options mean the same thing
verbose = config.verbose || config.v;
dbg = config.debug || config.d;

%% main command
fullInputVolume = fullfile(pathToWorkspace, config.inputVolume);
fullOutputVolume = fullfile(pathToWorkspace, config.outputVolume);
command = 'bet %s %s';
command = sprintf(command, fullInputVolume, fullOutputVolume);

%% type
% select main type of extraction (mutually exclusive options)
if ~isempty(config.type)
  command = strcat([command ' -' config.type]);
end

%% options
% generate brain surface outline overlaid onto original image
if config.o
  command = strcat([command ' -o']);
end

% generate binary brain mask
if config.m
  command = strcat([command ' -m']);
end

% generate approximate skull image
if config.s
  command = strcat([command ' -s']);
end

% don't generate segmented brain image output
if config.n
  command = strcat([command ' -n']);
end

% fractional intensity threshold (0->1); default=0.5;
% smaller values give larger brain outline estimates
if config.f
  command = sprintf('%s -f %.4f', command, config.f);
end

% vertical gradient in fractional intensity threshold (-1->1); default=0;
% positive values give larger brain outline at bottom, smaller at top
if config.g
  command = sprintf('%s -g %.4f', command, config.g);
end

% apply thresholding to segmented brain image and mask
if config.t
  command = sprintf('%s -t', command);
end

% generates brain surface as mesh in .vtk format
if config.e
  command = sprintf('%s -e', command);
end

% verbose (switch on diagnostic messages)
if verbose
  command = strcat([command ' -v']);
end

% debug (don't delete temporary intermediate images)
if dbg
  command = strcat([command ' -d']);
end

%% execute
[status, result] = CallSystem(command, verbose);

end

