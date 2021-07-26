function [sequence] = BuildBrainExtractionSequence(inputs, subjectName, pathToWorkspace, pathToOutput)
%BUILDBRAINEXTRACTIONSEQUENCE Example of a sequence builder for brain extraction.
%   This sequence builder runs brain extraction of a T1w image.
%   
%   Input:
%   - inputs:           Inputs that will be copied into the workspace.
%   - pathToWorkspace:  Path to the sequence's workspace.
%   - pathToOutput:     Path to where we will output the data.
%
%   Output:
%   - sequence:  Built sequence.

%% step 1
% extract brain
params = {};
config = {};
params.inputFile = sprintf('%s_T1w.nii.gz', subjectName);
params.outputFile = sprintf('%s_T1w_brain.nii.gz', subjectName);
config.type = 'R';
config.f = 0.4;
% creates mask
config.m = true;
config.verbose = true;
deps = { params.inputFile };
step1 = Step(@ExtractBrain, params, deps, config);

%% step 2
% fill mask
params = {};
config = {};
params.inputFile = sprintf('%s_T1w_brain_mask.nii.gz', subjectName);
params.outputFile = sprintf('%s_T1w_brain_mask_filled.nii.gz', subjectName);
config.verbose = true;
deps = { params.inputFile };
step2 = Step(@FillMask, params, deps, config);

%% step 3
% multiply brain by mask
% extra step to be very precise on the extraction
params = {};
config = {};
params.inputFile1 = sprintf('%s_T1w.nii.gz', subjectName);
params.inputFile2 = sprintf('%s_T1w_brain_mask_filled.nii.gz', subjectName);
params.outputFile = sprintf('%s_T1w_brain_mul.nii.gz', subjectName);
config.verbose = true;
deps = { params.inputFile1, params.inputFile2 };
step3 = Step(@MultiplyImages, params, deps, config);

% set up steps in order
steps = { step1, step2, step3 };

% these files will be copied from the workspace to the output path
outputs = { sprintf('%s_T1w_brain.nii.gz', subjectName), ...
            sprintf('%s_T1w_brain_mask_filled.nii.gz', subjectName), ...
            sprintf('%s_T1w_brain_mul.nii.gz', subjectName) };

sequence = Sequence(steps, ...
                    inputs, ...
                    outputs, ...
                    pathToWorkspace, ...
                    pathToOutput, ...
                    true);

end
