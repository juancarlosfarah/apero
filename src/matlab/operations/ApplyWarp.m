function [status, result] = ApplyWarp(pathToWorkspace, config)
%APPLYWARP Apply a non-linear mapping.
%   Uses `applywarp` to apply a non-linear mapping.
%
%   Input:
%   - pathToWorkspace:  Path to the workspace.
%   - config:           Configuration to be used in the operation.
%
%   Output:
%   - status:  Status returned by system call.
%   - result:  Result returned by system call.
%
% Usage: 
% applywarp -i invol -o outvol -r refvol -w warpvol
% applywarp -i invol -o outvol -r refvol -w coefvol
% applywarp -i invol -o outvol -r refvol --usesqform
% 
% Optional arguments (You may optionally specify one or more of):
% 	--abs		treat warp field as absolute: x' = w(x)
% 	--rel		treat warp field as relative: x' = x + w(x)
% 	-d,--datatype	Force output data type [char short int float double].
% 	-s,--super	intermediary supersampling of output, default is off
% 	--superlevel	level of intermediary supersampling, a for 'automatic' or integer level. Default = 2
% 	--premat	filename for pre-transform (affine matrix)
% 	--postmat	filename for post-transform (affine matrix)
% 	-m,--mask	filename for mask image (in reference space)
% 	--paddingsize	Extrapolates outside original volume by n voxels
% 	--usesqform	use s/qforms of --ref and --in images

arguments
  pathToWorkspace char = '.'
  % filename of input image (to be warped)
  config.inputVolume char
  % filename for output (warped) image
  config.outputVolume char
  % filename for reference image
  config.referenceVolume char
  % filename for warp/coefficient (volume)
  config.warpVolume char = ''
  % interpolation method
  config.interp char {mustBeMember(config.interp, { ...
    'nn', ...
    'sinc', ...
    'trilinear', ...
    'spline' ...
  })} = 'trilinear'
  % switch on diagnostic messages
  config.verbose logical = false
  config.v logical = false
end

%% main command
fullInputVolume = fullfile(pathToWorkspace, config.inputVolume);
fullReferenceVolume = fullfile(pathToWorkspace, config.referenceVolume);
fullOutputVolume = fullfile(pathToWorkspace, config.outputVolume);
command = 'applywarp --in=%s --ref=%s --out=%s';
command = sprintf(command, ...
                  fullInputVolume, ...
                  fullReferenceVolume, ...
                  fullOutputVolume);

%% secondary input
% filename for warp/coefficient (volume)
if config.warpVolume
  fullWarpVolume = fullfile(pathToWorkspace, config.warpVolume);
  command = sprintf('%s --warp=%s', command, fullWarpVolume);
end

%% options
% image interpolation model
if config.interp
  command = sprintf('%s --interp=%s', command, config.interp);
end

% verbose (switch on diagnostic messages)
if config.verbose || config.v
  command = sprintf('%s -v', command);
end
                 
[status, result] = CallSystem(command, config.verbose);

end
