function [status, result] = CorrectMotion(pathToWorkspace, config)
%CORRECTMOTION Motion correct a timeseries.
%   Uses `mcflirt` to motion correct a timeseries.
%
%   Input:
%   - pathToWorkspace:  Path to the workspace.
%   - config:           Configuration to be used in the operation.
%
%   Output:
%   - status:  Status returned by system call.
%   - result:  Result returned by system call.
%
% TODO:
%   -cost {mutualinfo,woods,corratio,normcorr,normmi,leastsquares}        (default is normcorr)
%   -bins <number of histogram bins>   (default is 256)
%   -dof  <number of transform dofs>   (default is 6)
%   -refvol <number of reference volume> (default is no_vols/2)- registers to (n+1)th volume in series
%   -reffile, -r <filename>            use a separate 3d image file as the target for registration (overrides refvol option)
%   -scaling <num>                             (6.0 is default)
%   -smooth <num>                      (1.0 is default - controls smoothing in cost function)
%   -rotation <num>                    specify scaling factor for rotation optimization tolerances
%   -verbose <num>                     (0 is least and default)
%   -stages <number of search levels>  (default is 3 - specify 4 for final sinc interpolation)
%   -fov <num>                         (default is 20mm - specify size of field of view when padding 2d volume)
%   -2d                                Force padding of volume
%   -sinc_final                        (applies final transformations using sinc interpolation)
%   -spline_final                      (applies final transformations using spline interpolation)
%   -nn_final                          (applies final transformations using Nearest Neighbour interpolation)
%   -init <filename>                   (initial transform matrix to apply to all vols)
%   -gdt                               (run search on gradient images)
%   -stats                             produce variance and std. dev. images
%   -mats                              save transformation matricies in subdirectory outfilename.mat
%   -report                            report progress to screen

arguments
  pathToWorkspace char = '.'
  config.inputVolume char
  % default is infile_mcf
  config.outputVolume char
  % save transformation parameters in file outputfilename.par
  config.plots logical = false
  % register timeseries to mean volume (overrides refvol and reffile options)
  config.meanvol logical = false
  % file to save regressors
  config.regressorsFile char
  % switch on diagnostic messages
  config.verbose logical = false
  config.v logical = false
end

% normalize if multiple options mean the same thing
verbose = config.verbose || config.v;

fullInputVolume = fullfile(pathToWorkspace, config.inputVolume);

command = 'mcflirt -in %s';
command = sprintf(command, fullInputVolume);

if isfield(config, 'outputVolume')
  fullOutputVolume = fullfile(pathToWorkspace, config.outputVolume);
  command = sprintf('%s -o %s', command, fullOutputVolume);
end

% save transformation parameters in file outputfilename.par
if config.plots
  command = sprintf('%s -plots', command);
end

% register timeseries to mean volume (overrides refvol and reffile options)
if config.meanvol
  command = sprintf('%s -meanvol', command);
end

if verbose
  command = sprintf('%s -verbose 1 -report', command);
end

[status, result] = CallSystem(command, verbose);

%% values and derivatives of 6 motion regressors
if config.plots && isfield(config, 'regressorsFile')
  plotsFile = sprintf('%s.par', config.outputVolume);
  
  % the par file contains the six nuisance regressors corresponding to
  % three directions of translation and three axes of rotation
  motion = load(fullfile(pathToWorkspace, plotsFile));
  
  % derivatives of 6 motion regressors
  deriv = nan(size(motion));
  for i = 1 : size(motion, 2)
    m = motion(:, i)';
    mDeriv = [0, diff(m)];
    deriv(:, i) = mDeriv';
  end
  
  regressorsFile = fullfile(pathToWorkspace, config.regressorsFile);
  save(regressorsFile, 'motion', 'deriv');

end