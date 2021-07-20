function [status, result] = ExtractBrain(pathToWorkspace, ...
                                         params, ...
                                         config)
%EXTRACTBRAIN Summary of this function goes here
%   Extracts brain from fMRI data using FSL's `bet`.
%
%   Input:
%   - pathToWorkspace:  ...
%   - params:           ...
%   - config:           ...
%
%   Output:
%   - status:  ...
%   - result:   ...  

arguments
  pathToWorkspace string = '.'
  params.inputFile string
  params.outputFolder string
  % variations on default bet2 functionality (mutually exclusive options):
  config.type string {mustBeMember(config.type, { ...
    'R', ... % robust brain centre estimation (iterates BET several times)
    'S', ... % eye & optic nerve cleanup (can be useful in SIENA - disables -o option)
    'B', ... % bias field & neck cleanup (can be useful in SIENA)    
    'Z', ... % improve BET if FOV is very small in Z (by temporarily padding end slices)
    'F', ... % apply to 4D FMRI data (uses -f 0.3 and dilates brain mask slightly)
    'A'      % run bet2 and then betsurf to get additional skull and scalp surfaces (includes registrations)
  })} = ''
  % generate brain surface outline overlaid onto original image
  config.o boolean = false
  % generate binary brain mask
  config.m boolean = false
  % generate approximate skull image
  config.s boolean = false
  % don't generate segmented brain image output
  config.n boolean = false
  % fractional intensity threshold (0->1); default=0.5;
  % smaller values give larger brain outline estimates
  config.f float {mustBeInRange(config.f, 0, 1)} = 0.5
  % vertical gradient in fractional intensity threshold (-1->1); default=0;
  % positive values give larger brain outline at bottom, smaller at top
  config.g float {mustBeInRange(config.g, -1, 1)} = 0
  % apply thresholding to segmented brain image and mask
  config.t boolean = false
  % generates brain surface as mesh in .vtk format
  config.e boolean = false
  % debug (don't delete temporary intermediate images)
  config.debug boolean = false
  config.d boolean = false
  % verbose (switch on diagnostic messages)
  config.verbose boolean = false
  config.v boolean = false
end

%% main command
fullInputFile = fullfile(pathToWorkspace, params.inputFile);
fullOutputFile = fullfile(pathToWorkspace, params.outputFolder);
command = 'bet %s %s';
command = sprintf(command, fullInputFile, fullOutputFile);

%% type
% select main type of extraction (mutually exclusive options)
if ~isempty(type)
  command = strcat([command ' -' type]);
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
if config.verbose || config.v
  command = strcat([command ' -v']);
end

% debug (don't delete temporary intermediate images)
if config.debug || config.d
  command = strcat([command ' -d']);
end

%% execute
[status, result] = CallSystem(command, verbose);

end

