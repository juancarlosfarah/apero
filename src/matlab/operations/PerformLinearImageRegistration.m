function [status, result, command] = PerformLinearImageRegistration(pathToWorkspace, ...
                                                           config)
%PERFORMLINEARIMAGEREGISTRATION Perform linear image registration using `flirt`.
%   Uses `flirt` to perform linear image registration.
%   
%   If operation fails, returns a nonzero value in status and an
%   explanatory message in result.
%
%   Input:
%   - pathToWorkspace:  Path to the workspace.
%   - config:           Configuration to be used in the operation.
%
%   Output:
%   - status:  Status returned by system call.
%   - result:  Result returned by system call.
%
% Usage: flirt [options] -in <inputvol> -ref <refvol> -out <outputvol>
%        flirt [options] -in <inputvol> -ref <refvol> -omat <outputmatrix>
%        flirt [options] -in <inputvol> -ref <refvol> -applyxfm -init <matrix> -out <outputvol>
% 
% TODO:
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

arguments
  pathToWorkspace char = '.'
  config.inputVolume char
  config.referenceVolume char
  config.outputVolume char = ''
  config.outputMatrix char = ''
  % input 4x4 affine matrix
  config.initMatrix char = ''
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
  % white matter segmentation volume needed by BBR cost function
  config.wmseg char
  % white matter boundary coordinates for BBR cost function
  config.wmcoords char
  % white matter boundary normals for BBR cost function
  config.wmnorms char
  % switch on diagnostic messages
  config.verbose logical = false
  config.v logical = false
end

% normalize if multiple options mean the same thing
verbose = config.verbose || config.v;

%% main command
fullInputVolume = fullfile(pathToWorkspace, config.inputVolume);
fullReferenceVolume = fullfile(pathToWorkspace, config.referenceVolume);
command = 'flirt -in %s -ref %s';
command = sprintf(command, fullInputVolume, fullReferenceVolume);

%% options
% input 4x4 affine matrix
if ~isempty(config.initMatrix)
  fullInitMatrix = fullfile(pathToWorkspace, config.initMatrix);
  command = sprintf('%s -init %s', command, fullInitMatrix);
end

% output volume
if ~isempty(config.outputVolume)
  fullOutputVolume = fullfile(pathToWorkspace, config.outputVolume);
  command = sprintf('%s -o %s', command, fullOutputVolume);
end

% output in 4x4 ascii format
if ~isempty(config.outputMatrix)
  fullOutputMatrix = fullfile(pathToWorkspace, config.outputMatrix);
  command = sprintf('%s -omat %s', command, fullOutputMatrix);
end

% number of transform degrees of freedom
if config.dof
  command = sprintf('%s -dof %d', command, config.dof);
end

% final interpolation
if config.interp
  command = sprintf('%s -interp %s', command, config.interp);
end

% cost function
command = sprintf('%s -cost %s', command, config.cost);

% applies transform (no optimisation)
if config.applyxfm
  % requires init
  if isempty(config.initMatrix)
    % todo: throw error
    error = 'PerformLinearImageRegistration: applyxfm requires initMatrix parameter\n';
    fprintf(error);
    % signals error
    status = 1;
    result = error;
    return
  end
  command = sprintf('%s -applyxfm', command);
end

% boundary-based registration
if strcmp(config.cost, 'bbr')
  % requires wmseg
  if ~isfield(config, 'wmseg')
    % todo: throw error
    error = 'PerformLinearImageRegistration: -cost bbr requires wmseg parameter\n';
    fprintf(error);
    % signals error
    status = 1;
    result = error;
    return
  end
  % white matter segmentation volume needed by BBR cost function
  fullWmSeg = fullfile(pathToWorkspace, config.wmseg);
  command = sprintf('%s -wmseg %s', command, fullWmSeg);
  
  % white matter boundary coordinates for BBR cost function
  if isfield(config, 'wmcoords')
    fullWmCoords = fullfile(pathToWorkspace, config.wmcoords);
    command = sprintf('%s -wmcoords %s', command, fullWmCoords);
  end
  
  % white matter boundary normals for BBR cost function
  if isfield(config, 'wmnorms')
    fullWmNorms = fullfile(pathToWorkspace, config.wmnorms);
    command = sprintf('%s -wmnorms %s', command, fullWmNorms);
  end
end

% sets all angular search ranges to 0 0
if config.nosearch
  command = sprintf('%s -nosearch', command);
end

% verbose (switch on diagnostic messages)
if verbose
  command = sprintf('%s -v', command);
end

%% execute
[status, result] = CallSystem(command, verbose);

end

