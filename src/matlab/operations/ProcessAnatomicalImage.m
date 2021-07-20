function [status, result] = ProcessAnatomicalImage(pathToWorkspace, ...
                                                   params, ...
                                                   config)
%PROCESSANATOMICALIMAGE Processes an anatomical image using `fsl_anat`.
%   Uses `fsl_anat` to process an anatomical image.
%
%   Input:
%   - pathToWorkspace:  ...
%   - params:           ...
%   - config:           ...
%
%   Output:
%   - status:  ...
%   - result:   ...  

arguments
  pathToWorkspace string = '.'
  params.inputFile string
  params.outputFolder string
  config.clobber boolean = true
  config.noReg boolean = true
  config.noNonLinReg boolean = true
  config.noSeg boolean = true
  config.weakBias boolean = true
  config.noReorient boolean = true
  config.noCrop boolean = true
  config.verbose boolean = false
end

% run `fsl_anat` (it should be in the path)
% options:
% -i <image>      filename of input image (for one image only)
% -o <output>     basename of directory for output (default is input image basename followed by .anat) 
% input:  T1_denoised (file)
% output: T1_denoised.anat (directory)

fullInputFile = fullfile(pathToWorkspace, params.inputFile);
fullOutputFolder = fullfile(pathToWorkspace, params.outputFolder);
command = 'fsl_anat';

% if .anat directory exist then delete it and make a new one
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

[status, result] = CallSystem(sentence, verbose);

end
