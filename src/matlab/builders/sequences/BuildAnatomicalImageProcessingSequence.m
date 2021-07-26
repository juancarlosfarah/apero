function [sequence] = BuildAnatomicalImageProcessingSequence(inputs, subjectName, pathToWorkspace, pathToOutput)
%BUILDANATOMICALIMAGEPROCESSINGSEQUENCE Example of a sequence builder to
%process anatomical images.
%
%   This sequence builder runs the ProcessAnatomicalImage operation.
%   
%   Input:
%   - inputs:           Inputs that will be copied into the workspace.
%   - pathToWorkspace:  Path to the sequence's workspace.
%   - pathToOutput:     Path to where we will output the data.
%
%   Output:
%   - sequence:  Built sequence.

%% step 1
% process anatomical image
params = {};
config = {};
params.inputFile = sprintf('%s_T1w.nii.gz', subjectName);
params.outputFolder = sprintf('%s_T1w', subjectName);
config.verbose = true;
deps = { params.inputFile };
step1 = Step(@ProcessAnatomicalImage, params, deps, config);

% set up steps in order
steps = { step1 };

% these files will be copied from the workspace to the output path
outputs = { sprintf('%s_T1w.nii.gz', subjectName)  ...
            sprintf('%s_T1w.anat/T1_biascorr.nii.gz', subjectName)};

sequence = Sequence(steps, ...
                    inputs, ...
                    outputs, ...
                    pathToWorkspace, ...
                    pathToOutput, ...
                    false);

end
