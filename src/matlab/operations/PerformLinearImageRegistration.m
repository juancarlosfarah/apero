function [status, result] = PerformLinearImageRegistration(pathToWorkspace, ...
                                                           params, ...
                                                           config)
%PERFORMLINEARIMAGEREGISTRATION Perform linear image registration using `flirt`.
%   Uses `flirt` to perform linear image registration.
%   
%   If operation fails, returns a nonzero value in status and an
%   explanatory message in result.
%
%   Input:
%   - pathToWorkspace:  ...
%   - params:           ...
%   - config:           ...
%
%   Output:
%   - status:  ...
%   - result:  ...  
%
% Usage: flirt [options] -in <inputvol> -ref <refvol> -out <outputvol>
%        flirt [options] -in <inputvol> -ref <refvol> -omat <outputmatrix>
%        flirt [options] -in <inputvol> -ref <refvol> -applyxfm -init <matrix> -out <outputvol>
% 
%   Available options are:
%         -in  <inputvol>                    (no default)
%         -ref <refvol>                      (no default)
%         -out, -o <outputvol>               (default is none)
%         -datatype {char,short,int,float,double}                    (force output data type)
%         -searchcost {mutualinfo,corratio,normcorr,normmi,leastsq,labeldiff,bbr}  (default is corratio)
%         -usesqform                         (initialise using appropriate sform or qform)
%         -displayinit                       (display initial matrix)
%         -anglerep {quaternion,euler}       (default is euler)
%         -sincwidth <full-width in voxels>  (default is 7)
%         -sincwindow {rectangular,hanning,blackman}
%         -bins <number of histogram bins>   (default is 256)
%         -noresample                        (do not change input sampling)
%         -forcescaling                      (force rescaling even for low-res images)
%         -minsampling <vox_dim>             (set minimum voxel dimension for sampling (in mm))
%         -applyisoxfm <scale>               (as applyxfm but forces isotropic resampling)
%         -paddingsize <number of voxels>    (for applyxfm: interpolates outside image by size)
%         -searchrx <min_angle> <max_angle>  (angles in degrees: default is -90 90)
%         -searchry <min_angle> <max_angle>  (angles in degrees: default is -90 90)
%         -searchrz <min_angle> <max_angle>  (angles in degrees: default is -90 90)
%         -coarsesearch <delta_angle>        (angle in degrees: default is 60)
%         -finesearch <delta_angle>          (angle in degrees: default is 18)
%         -schedule <schedule-file>          (replaces default schedule)
%         -refweight <volume>                (use weights for reference volume)
%         -inweight <volume>                 (use weights for input volume)
%         -wmseg <volume>                    (white matter segmentation volume needed by BBR cost function)
%         -wmcoords <text matrix>            (white matter boundary coordinates for BBR cost function)
%         -wmnorms <text matrix>             (white matter boundary normals for BBR cost function)
%         -fieldmap <volume>                 (fieldmap image in rads/s - must be already registered to the reference image)
%         -fieldmapmask <volume>             (mask for fieldmap image)
%         -pedir <index>                     (phase encode direction of EPI - 1/2/3=x/y/z & -1/-2/-3=-x/-y/-z)
%         -echospacing <value>               (value of EPI echo spacing - units of seconds)
%         -bbrtype <value>                   (type of bbr cost function: signed [default], global_abs, local_abs)
%         -bbrslope <value>                  (value of bbr slope)
%         -setbackground <value>             (use specified background value for points outside FOV)
%         -noclamp                           (do not use intensity clamping)
%         -noresampblur                      (do not use blurring on downsampling)
%         -2D                                (use 2D rigid body mode - ignores dof)
%         -i                                 (pauses at each stage: default is off)
%         -version                           (prints version number)
%         -help

arguments
  pathToWorkspace char = '.'
  params.inputVolume char
  params.referenceVolume char
  params.outputVolume char = ''
  params.outputMatrix char = ''
  % input 4x4 affine matrix
  params.initMatrix char = ''
  % number of transform degrees of freedom
  config.dof int8 = 12
  % applies transform (no optimisation) - requires -init
  config.applyxfm logical = false
  % sets all angular search ranges to 0 0
  config.nosearch logical = false
  % final interpolation
  config.interp char {mustBeMember(config.interp, { ...
    'trilinear', ...
    'nearestneighbour', ...
    'sinc', ...
    'spline' ...
  })} = 'trilinear'
  % cost function (default is corratio)
  config.cost char {mustBeMember(config.cost, { ...
    'mutualinfo', ...
    'corratio', ...
    'normcorr', ...
    'normmi', ...
    'leastsq', ...
    'labeldiff', ...
    'bbr' ...
  })} = 'corratio'
  config.verbose logical = false
  config.v logical = false
end

%% main command
fullInputVolume = fullfile(pathToWorkspace, params.inputVolume);
fullReferenceVolume = fullfile(pathToWorkspace, params.referenceVolume);
command = 'flirt -in %s -ref %s';
command = sprintf(command, fullInputVolume, fullReferenceVolume);

%% secondary params
% input 4x4 affine matrix
if ~isempty(params.initMatrix)
  fullInitMatrix = fullfile(pathToWorkspace, params.initMatrix);
  command = sprintf('%s -init %s', command, fullInitMatrix);
end

% output volume
if ~isempty(params.outputVolume)
  fullOutputVolume = fullfile(pathToWorkspace, params.outputVolume);
  command = sprintf('%s -o %s', command, fullOutputVolume);
end

% output in 4x4 ascii format
if ~isempty(params.outputMatrix)
  fullOutputMatrix = fullfile(pathToWorkspace, params.outputMatrix);
  command = sprintf('%s -omat %s', command, fullOutputMatrix);
end

%% options
% number of transform degrees of freedom
if config.dof
  command = sprintf('%s -dof %d', command, config.dof);
end

% final interpolation
if config.interp
  command = sprintf('%s -interp %s', command, config.interp);
end

% cost function
if config.cost
  command = sprintf('%s -cost %s', command, config.cost);
end

% applies transform (no optimisation)
if config.applyxfm
  % requires init
  if ~params.initMatrix
    % todo: throw error
    error = 'PerformLinearImageRegistration: applyxfm requires initMatrix parameter';
    fprintf(error);
    % signals error
    status = 1;
    result = error;
    return
  end
  command = sprintf('%s -applyxfm', command);
end

% sets all angular search ranges to 0 0
if config.nosearch
  command = sprintf('%s -nosearch', command);
end

% verbose (switch on diagnostic messages)
if config.verbose || config.v
  command = sprintf('%s -v', command);
end

%% execute
[status, result] = CallSystem(command, config.verbose);

end

