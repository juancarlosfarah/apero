function [sequence] = BuildTransformParcellationSequence(inputs, ...
                                                         parcellation, ...
                                                         subjectName, ...
                                                         pathToWorkspace, ...
                                                         pathToOutput, ...
                                                         config)
%BUILDTRANSFORMPARCELLATIONSEQUENCE Example of a sequence builder.
%   This builder creates a sequence that applies a registration to a given
%   parcellation.
%
%   Input:
%   - inputs:           Inputs that will be copied into the workspace.
%   - pathToWorkspace:  Path to the sequence's workspace.
%   - pathToOutput:     Path to where we will output the data.
%
%   Output:
%   - sequence:  Built sequence.

parcellationName = extractBefore(parcellation, '.');

%% step 1
% dilate parcellation
step1Params = {};
step1Config = config.step1;
step1Params.inputVolume = parcellation;
step1Params.outputVolume = sprintf('%s_dil.nii.gz', parcellationName);
deps1 = { step1Params.inputVolume };
outputs1 = { step1Params.outputVolume };
step1 = Step(@Dilate, ...
             step1Params, ...
             deps1, ...
             step1Config, ...
             outputs1);

%% step 2
% apply inverse warp to parcellation to go down to dof 12
step2Params = {};
step2Config = config.step2;
% support skipping step 1, so taking the parcellation directly as input
if isfield(config.step1, 'skip') && config.step1.skip
  step2Params.inputVolume = parcellation;
else
  step2Params.inputVolume = step1Params.outputVolume;
end
step2Params.referenceVolume = sprintf('%s_T1w_brain_dof12.nii.gz', subjectName);
step2Params.warpVolume = sprintf('%s_MNI2T1w_warp.nii.gz', subjectName);
step2Params.outputVolume = sprintf('%s_invwarp.nii.gz', parcellationName);
deps2 = { step2Params.inputVolume, ...
          step2Params.referenceVolume,  ...
          step2Params.warpVolume };
outputs2 = { step2Params.outputVolume };
step2 = Step(@ApplyWarp, ...
             step2Params, ...
             deps2, ...
             step2Config, ...
             outputs2);

%% step 3
% apply inverted dof 12 transform to parcellation to go down to dof 6
step3Params = {};
step3Config = config.step3;
step3Params.inputVolume = step2Params.outputVolume;
step3Params.referenceVolume = sprintf('%s_T1w_brain_dof6.nii.gz', subjectName);
step3Params.initMatrix = sprintf('%s_MNI2T1w_dof12.mat', subjectName);
step3Params.outputVolume = sprintf('%s_invdof12.nii.gz', parcellationName);
deps3 = { step3Params.inputVolume, ...
          step3Params.referenceVolume,  ...
          step3Params.initMatrix };
outputs3 = { step3Params.outputVolume };
step3 = Step(@PerformLinearImageRegistration, ...
             step3Params, ...
             deps3, ...
             step3Config, ...
             outputs3);

%% step 4
% apply inverted dof 6 transform to parcellation to go down to native
step4Params = {};
step4Config = config.step4;
step4Params.inputVolume = step3Params.outputVolume;
step4Params.referenceVolume = sprintf('%s_T1w_brain_mul.nii.gz', subjectName);
step4Params.initMatrix = sprintf('%s_MNI2T1w_dof6.mat', subjectName);
step4Params.outputVolume = sprintf('%s_%s.nii.gz', parcellationName, subjectName);
deps4 = { step4Params.inputVolume, ...
          step4Params.referenceVolume,  ...
          step4Params.initMatrix };
outputs4 = { step4Params.outputVolume };
step4 = Step(@PerformLinearImageRegistration, ...
             step4Params, ...
             deps4, ...
             step4Config, ...
             outputs4);


%% prepare the sequence
% set up steps in order
steps = { step1, ...
          step2, ...
          step3, ...
          step4 };

% these files will be copied from the workspace to the output path
outputs = { step4Params.outputVolume }; % registered parcellation

sequence = Sequence(steps, ...
                    inputs, ...
                    outputs, ...
                    pathToWorkspace, ...
                    pathToOutput, ...
                    true);

end
