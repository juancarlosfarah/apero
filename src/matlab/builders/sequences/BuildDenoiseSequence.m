function [sequence] = BuildDenoiseSequence(inputs, subjectName, pathToWorkspace, pathToOutput)
%BUILDDENOISESEQUENCE Example of a sequence builder to denoise images.
%   This sequence builder runs the DenoiseImage operation.
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
params.inputFile = sprintf('%s_T1w.nii.gz', subjectName);
params.outputFile = sprintf('%s_T1w_denoised.nii', subjectName);
config.verbose = true;
deps = { params.inputFile };
step1 = Step(@DenoiseImage, params, deps, config);

% set up steps in order
steps = { step1 };

% these files will be copied from the workspace to the output path
outputs = { sprintf('%s_T1w.nii.gz', subjectName)  ...
            sprintf('%s_T1w_denoised.nii', subjectName)};

sequence = Sequence(steps, ...
                    inputs, ...
                    outputs, ...
                    pathToWorkspace, ...
                    pathToOutput, ...
                    false);

end
