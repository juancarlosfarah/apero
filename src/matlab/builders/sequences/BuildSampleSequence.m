function [sequence] = BuildSampleSequence(inputs, pathToWorkspace, pathToOutput)
%BUILDSAMPLESEQUENCE Example of a sequence builder.
%   This sequence builder runs the typical basic processing of a T1w image.
%   
%   Input:
%   - inputs:           Inputs that will be copied into the workspace.
%   - pathToWorkspace:  Path to the sequence's workspace.
%   - pathToOutput:     Path to where we will output the data.
%
%   Output:
%   - sequence:  Built sequence.

%% step 1
% denoise
params = {};
config = {};
params.inputFile = 'T1w.nii.gz';
params.outputFile = 'T1w_denoised.nii';
deps = { params.inputFile };
step1 = Step(@DenoiseImage, params, deps, config);

%% step 2
% process anatomical image
params = {};
config = {};
params.inputFile = 'T1w_denoised.nii';
params.outputFolder = 'T1w_denoised.anat';
deps = { params.inputFile };
step2 = Step(@BuildProcessAnatomicalImageStep, params, deps, config);

%% step 3
% extract brain
params = {};
config = {};
params.inputFile = 'T1w_denoised.anat/T1_biascorr.nii.gz';
params.outputFile = 'T1w_brain.nii.gz';
config.type = 'R';
config.f = 0.4;
deps = { inputFile };
step3 = Step(@ExtractBrain, params, deps, config);

%% step 4
% fill mask
params = {};
config = {};
params.inputFile = 'T1w_brain_mask.nii.gz';
params.outputFile = 'T1w_brain_mask_filled.nii.gz';
deps = { params.inputFile };
step4 = Step(@FillMask, params, deps, config);

%% step 5
% multiply brain by mask
% extra step to be very precise on the extraction
params = {};
config = {};
params.inputFile1 = 'T1w_denoised.anat/T1_biascorr.nii.gz';
params.inputFile2 = 'T1w_brain_mask_filled.nii.gz';
params.outputFile = 'T1w_brain_mul.nii.gz';
deps = { params.inputFile1, params.inputFile2 };
step5 = Step(@MultiplyImages, params, deps, config);

% set up steps in order
steps = { step1, step2, step3, step4, step5 };

% these files will be copied from the workspace to the output path
outputs = { 'T1w.nii.gz',  ...
            'T1w_brain.nii.gz', ...
            'T1w_brain_mask_filled.nii.gz', ...
            'T1w_brain_mul.nii.gz' };

sequence = Sequence(steps, ...
                    inputs, ...
                    outputs, ...
                    pathToWorkspace, ...
                    pathToOutput, ...
                    false);

end
