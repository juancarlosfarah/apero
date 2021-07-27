function [sequence] = BuildRegisterParcellationSequence(inputs, ...
                                                        subjectName, ...
                                                        pathToWorkspace, ...
                                                        pathToOutput)
%BUILDREGITERPARCELLATIONSEQUENCE Example of a sequence builder.
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
% flirt dof 6
params = {};
config = {};
params.inputVolume = sprintf('%s_T1w_brain_mul.nii.gz', subjectName);
params.referenceVolume = 'ch2bet';
params.outputVolume = sprintf('%s_T1w_brain_dof6.nii.gz', subjectName);
params.outputMatrix = sprintf('%s_T1w2MNI_dof6.mat', subjectName);
config.dof = 6;
config.interp = 'spline';
config.verbose = true;
deps = { params.inputVolume, params.referenceVolume };
step1 = Step(@PerformLinearImageRegistration, params, deps, config);

% set up steps in order
steps = { step1 };

% these files will be copied from the workspace to the output path
outputs = { sprintf('%s_T1w_brain_dof6.nii.gz', subjectName)  ...
            sprintf('%s_T1w2MNI_dof6.mat', subjectName) };

sequence = Sequence(steps, ...
                    inputs, ...
                    outputs, ...
                    pathToWorkspace, ...
                    pathToOutput, ...
                    false);

end
