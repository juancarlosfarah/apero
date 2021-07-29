function [status, result] = ApplyWarp(pathToWorkspace, ...
                                       params, ...
                                       config)
%APPLYWARP Apply a non-linear mapping.
%   Uses `applywarp` to apply a non-linear mapping.
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
  params.inputVolume char
  % filename for output (warped) image
  params.outputVolume char
  % filename for reference image
  params.referenceVolume char
  % filename for warp/coefficient (volume)
  params.warpVolume char = ''
  % interpolation method
  config.interp char {mustBeMember(config.interp, { ...
    'nn', ...
    'sinc', ...
    'trilinear', ...
    'spline' ...
  })} = 'trilinear'
  % clobber previous output
  config.clobber logical = false
  % switch on diagnostic messages
  config.verbose logical = false
  config.v logical = false
end

%% main command
fullInputVolume = fullfile(pathToWorkspace, params.inputVolume);
fullReferenceVolume = fullfile(pathToWorkspace, params.referenceVolume);
fullOutputVolume = fullfile(pathToWorkspace, params.outputVolume);
command = 'applywarp --in=%s --ref=%s --out=%s';
command = sprintf(command, ...
                  fullInputVolume, ...
                  fullReferenceVolume, ...
                  fullOutputVolume);

%% secondary params
% filename for warp/coefficient (volume)
if params.warpVolume
  fullWarpVolume = fullfile(pathToWorkspace, params.warpVolume);
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
