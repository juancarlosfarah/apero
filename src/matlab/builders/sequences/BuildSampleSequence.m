function [sequence] = BuildSampleSequence(inputs, ...
                                          subjectName, ...
                                          pathToWorkspace, ...
                                          pathToOutput, ...
                                          config)
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
step1Params = {};
step1Config = {};
step1Params.inputFile = sprintf('%s_T1w.nii.gz', subjectName);
step1Params.outputFile = sprintf('%s_T1w_denoised.nii', subjectName);
% verbose can be inherited from sequence config
step1Config.verbose = config.verbose;
deps = { step1Params.inputFile };
step1 = Step(@DenoiseImage, step1Params, deps, step1Config);

%% step 2
% process anatomical image
step2Params = {};
step2Config = {};
step2Params.inputFile = sprintf('%s_T1w_denoised.nii', subjectName);
step2Params.outputFolder = sprintf('%s_T1w_denoised', subjectName);
step2Config.verbose = config.verbose;
deps = { step2Params.inputFile };
step2 = Step(@ProcessAnatomicalImage, step2Params, deps, step2Config);

%% step 3
% extract brain
step3Params = {};
% you can also assign a dedicated step configuration object
step3Config = config.bet;
step3Params.inputFile = sprintf('%s_T1w_denoised.anat/T1_biascorr.nii.gz', subjectName);
step3Params.outputFile = sprintf('%s_T1w_brain.nii.gz', subjectName);
deps = { step3Params.inputFile };
step3 = Step(@ExtractBrain, step3Params, deps, step3Config);

%% step 4
% fill mask
step4Params = {};
step4Config = {};
step4Params.inputFile = sprintf('%s_T1w_brain_mask.nii.gz', subjectName);
step4Params.outputFile = sprintf('%s_T1w_brain_mask_filled.nii.gz', subjectName);
step4Config.verbose = config.verbose;
deps = { step4Params.inputFile };
step4 = Step(@FillMask, step4Params, deps, step4Config);

%% step 5
% multiply brain by mask
% extra step to be very precise on the extraction
step5Params = {};
step5Config = {};
step5Params.inputFile1 = sprintf('%s_T1w_denoised.anat/T1_biascorr.nii.gz', subjectName);
step5Params.inputFile2 = sprintf('%s_T1w_brain_mask_filled.nii.gz', subjectName);
step5Params.outputFile = sprintf('%s_T1w_brain_mul.nii.gz', subjectName);
step5Config.verbose = config.verbose;
deps = { step5Params.inputFile1, step5Params.inputFile2 };
step5 = Step(@MultiplyImages, step5Params, deps, step5Config);

% set up steps in order
steps = { step1, step2, step3, step4, step5 };

% these files will be copied from the workspace to the output path
outputs = { sprintf('%s_T1w.nii.gz', subjectName)  ...
            sprintf('%s_T1w_brain.nii.gz', subjectName), ...
            sprintf('%s_T1w_brain_mask_filled.nii.gz', subjectName), ...
            sprintf('%s_T1w_brain_mul.nii.gz', subjectName) };

sequence = Sequence(steps, ...
                    inputs, ...
                    outputs, ...
                    pathToWorkspace, ...
                    pathToOutput, ...
                    true);

end
