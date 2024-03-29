function [status, result, sentence] = ProcessAnatomicalImage(pathToWorkspace, config)
%PROCESSANATOMICALIMAGE Processes an anatomical image using `fsl_anat`.
%   Uses `fsl_anat` to process an anatomical image.
%   
%   Return status and result. A status of 0 signals everything went fine
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

arguments
  pathToWorkspace string = '.'
  config.inputFile string
  config.outputFolder string
  config.clobber logical = true
  config.noReg logical = true
  config.noNonLinReg logical = true
  config.noSeg logical = true
  config.weakBias logical = true
  config.noReorient logical = true
  config.noCrop logical = true
  config.verbose logical = false
end

% run `fsl_anat` (it should be in the path)
% options:
% -i <image>      filename of input image (for one image only)
% -o <output>     basename of directory for output (default is input image basename followed by .anat) 
% input:  T1_denoised (file)
% output: T1_denoised.anat (directory)

fullInputFile = fullfile(pathToWorkspace, config.inputFile);
fullOutputFolder = fullfile(pathToWorkspace, config.outputFolder);
command = 'fsl_anat';

% if .anat directory exists then delete it and make a new one
if config.clobber
  command = strcat([command ' --clobber']);
end

% turn off steps that do registration to standard (FLIRT and FNIRT)
if config.noReg
  command = strcat([command ' --noreg']);
end

% turn off step that does non-linear registration (FNIRT)
if config.noNonLinReg
  command = strcat([command ' --nononlinreg']);
end

% turn off step that does tissue-type segmentation (FAST)
if config.noSeg
  command = strcat([command ' --noseg']);
end

% used for images with smoother, more typical, bias fields (default setting)
if config.weakBias
  command = strcat([command ' --weakbias']);
end

% turn off step that does reorientation 2 standard (fslreorient2std)
if config.noReorient
  command = strcat([command ' --noreorient']);
end

% turn off step that does automated cropping (robustfov)
if config.noCrop
  command = strcat([command ' --nocrop']);
end

% add input and output
command = strcat([command ' -i %s -o %s']);
sentence = sprintf(command, fullInputFile, fullOutputFolder);

% if operation fails, returns a nonzero value in
% status and an explanatory message in result
[status, result] = CallSystem(sentence, config.verbose);

end
