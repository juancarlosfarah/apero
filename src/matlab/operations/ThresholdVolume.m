function [status, result] = ThresholdVolume(pathToWorkspace, config)
%THRESHOLDVOLUME Threshold a volume.
%   Uses `fslmaths` to threshold an volume.
%
%   Input:
%   - pathToWorkspace:  Path to the workspace.
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
  config.inputVolume char
  % filename of output image
  config.outputVolume char
  % zero anything below the number
	% e.g. thr = 2 will zero values 1, 0, and under
  config.thr double
  % zero anything above the number
	% e.g. uthr = 3 will zero values 4, 5, and above
  config.uthr double
  % switch on diagnostic messages
  config.verbose logical = false
  config.v logical = false
end

% normalize if multiple options mean the same thing
verbose = config.verbose || config.v;

%% main command
fullInputVolume = fullfile(pathToWorkspace, config.inputVolume);
command = 'fslmaths %s';
command = sprintf(command, fullInputVolume);

%% options
% zero anything below the number
if isfield(config, 'thr')
  command = sprintf('%s -thr %.4f', command, config.thr);
end

% zero anything above the number
if isfield(config, 'uthr')
  command = sprintf('%s -uthr %.4f', command, config.uthr);
end

%% output
fullOutputVolume = fullfile(pathToWorkspace, config.outputVolume);
command = sprintf('%s %s', ...
                  command, ...
                  fullOutputVolume);

[status, result] = CallSystem(command, verbose);

end

