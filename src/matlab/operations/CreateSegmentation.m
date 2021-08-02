function [status, result] = CreateSegmentation(pathToWorkspace, ...
                                               params, ...
                                               config)
%CREATESEGMENTATION Segment an image.
%   Uses `fast` to create a segmentation.
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
%  TODO:
% 	-n,--class	number of tissue-type classes; default=3
% 	-I,--iter	number of main-loop iterations during bias-field removal; default=4
% 	-l,--lowpass	bias field smoothing extent (FWHM) in mm; default=20
% 	-t,--type	type of image 1=T1, 2=T2, 3=PD; default=T1
% 	-f,--fHard	initial segmentation spatial smoothness (during bias field estimation); default=0.02
% 	-g,--segments	outputs a separate binary image for each tissue type
% 	-a <standard2input.mat> initialise using priors; you must supply a FLIRT transform
% 	-A <prior1> <prior2> <prior3>    alternative prior images
% 	--nopve	turn off PVE (partial volume estimation)
% 	-b		output estimated bias field
% 	-B		output bias-corrected image
% 	-N,--nobias	do not remove bias field
% 	-S,--channels	number of input images (channels); default 1
% 	-P,--Prior	use priors throughout; you must also set the -a option
% 	-W,--init	number of segmentation-initialisation iterations; default=15
% 	-R,--mixel	spatial smoothness for mixeltype; default=0.3
% 	-O,--fixed	number of main-loop iterations after bias-field removal; default=4
% 	-s,--manualseg <filename> Filename containing intensities
% 	-p		outputs individual probability maps

arguments
  pathToWorkspace char = '.'
  % filename of input image
  params.inputVolume char
  % output basename
  config.out char
  % segmentation spatial smoothness
  config.H double {mustBeInRange(config.H, 0, 1)} = 0.1
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
command = 'fast';


%% options
% output basename
if config.out
  command = sprintf('%s --out=%s', command, config.out);
end

% segmentation spatial smoothness
if config.H
  command = sprintf('%s -H %.4f', command, config.H);
end

% verbose (switch on diagnostic messages)
if verbose
  command = sprintf('%s -v', command);
end

% add inputs at the end
fullInputVolume = fullfile(pathToWorkspace, params.inputVolume);
command = sprintf('%s %s', ...
                  command, ...
                  fullInputVolume);
                 
[status, result] = CallSystem(command, verbose);

end
