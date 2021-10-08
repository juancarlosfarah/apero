function [status, result] = HdBet(pathToWorkspace, config)
%HDBET Extracts brain using HD-BET.
%   Extracts brain from fMRI data using MIC-DKFZ's `hd-bet`.
%
%   Input:
%   - pathToWorkspace:  Path to the workspace.
%   - config:           Configuration to be used in the operation.
%
%   Output:
%   - status:  Status returned by system call.
%   - result:  Result returned by system call.

% Message from the authors of `hd-bet`:
% ########################
% If you are using hd-bet, please cite the following paper:
% Isensee F, Schell M, Tursunova I, Brugnara G, Bonekamp D, Neuberger U,
% Wick A, Schlemmer HP, Heiland S, Wick W,Bendszus M, Maier-Hein KH,
% Kickingereder P. Automated brain extraction of multi-sequence MRI using
% artificial neural networks. arXiv preprint arXiv:1901.11341, 2019.
% ########################

arguments
  pathToWorkspace char = '.'
  % Can be either a single file name or an input folder. If file: must be
  % nifti (.nii.gz) and can only be 3D. No support for 4d images, use
  % fslsplit to split 4d sequences into 3d images. If folder: all files
  % ending with .nii.gz within that folder will be brain extracted.
  config.input char
  % can be either a filename or a folder
  % if it does not exist, the folder will be created
  config.output char
  % can be either 'fast' or 'accurate'. Fast will use only one set of
  % parameters whereas accurate will use the five sets of parameters that
  % resulted from our cross-validation as an ensemble.
  config.mode char {mustBeMember(config.mode, { ...
    'fast', ... 
    'accurate'
  })} = 'fast'
  % used to set on which device the prediction will run. Must be either int
  % or str. Use int for GPU id or 'cpu' to run on CPU. When using CPU you
  % should consider disabling tta.
  config.device = 0
  % whether to use test time data augmentation (mirroring)
  config.tta logical = true
  % set to 0 to disable postprocessing
  % (remove all but the largest connected component in the prediction)
  config.pp logical = true
  % if set to 0 the segmentation mask will not be saved
  config.s logical = true
  % verbose (switch on diagnostic messages)
  config.verbose logical = false
  config.v logical = false
end

% normalize if multiple options mean the same thing
verbose = config.verbose || config.v;

%% main command
fullInputFile = fullfile(pathToWorkspace, config.input);
fullOutputFile = fullfile(pathToWorkspace, config.output);
command = 'hd-bet -i %s -o %s';
command = sprintf(command, fullInputFile, fullOutputFile);

% mode
command = sprintf('%s -mode %s', command, config.mode);

% device (must be either int or str)
if isnumeric(config.device)
  command = sprintf('%s -device %d', command, config.device);
else
  command = sprintf('%s -device %s', command, config.device);
end

% test time data augmentation
command = sprintf('%s -tta %d', command, config.tta);

% postprocessing
command = sprintf('%s -pp %d', command, config.pp);

% save mask
command = sprintf('%s -s %d', command, config.s);

%% execute
[status, result] = CallSystem(command, verbose);


end
