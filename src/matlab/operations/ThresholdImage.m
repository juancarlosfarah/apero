function [status, result] = ThresholdImage(pathToWorkspace, ...
                                           params, ...
                                           config)
%THRESHOLDIMAGE Threshold an image.
%   Uses `fslmaths` to threshold an image.
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
%  -thrp  : use following percentage (0-100) of ROBUST RANGE to threshold current image (zero anything below the number)
%  -thrP  : use following percentage (0-100) of ROBUST RANGE of non-zero voxels and threshold below
%  -uthrp : use following percentage (0-100) of ROBUST RANGE to upper-threshold current image (zero anything above the number)
%  -uthrP : use following percentage (0-100) of ROBUST RANGE of non-zero voxels and threshold above

arguments
  pathToWorkspace char = '.'
  % filename of input image
  params.inputVolume char
  % filename of output image
  params.outputVolume char
  % zero anything below the number
  config.thr double
  % zero anything above the number
  config.uthr double
  % optional step
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
fullInputVolume = fullfile(pathToWorkspace, params.inputVolume);
command = 'fslmaths %s';
command = sprintf(command, fullInputVolume);

%% options
% zero anything below the number
if config.thr
  command = sprintf('%s -thr %.4f', command, config.thr);
end

% zero anything above the number
if config.uthr
  command = sprintf('%s -uthr %.4f', command, config.uthr);
end

%% output
fullOutputVolume = fullfile(pathToWorkspace, params.outputVolume);
command = sprintf('%s %s', ...
                  command, ...
                  fullOutputVolume);

[status, result] = CallSystem(command, verbose);

end

