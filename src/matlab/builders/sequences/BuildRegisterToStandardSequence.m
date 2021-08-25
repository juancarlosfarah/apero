function [sequence] = BuildRegisterToStandardSequence(inputs, ...
                                                      subjectName, ...
                                                      pathToWorkspace, ...
                                                      pathToOutput, ...
                                                      config)
%BUILDREGISTERTOSTANDARDSEQUENCE Example of a sequence builder.
%   This builder creates the typical sequence to perform the registration
%   of a parcellation.
%
%   Input:
%   - inputs:           Inputs that will be copied into the workspace.
%   - pathToWorkspace:  Path to the sequence's workspace.
%   - pathToOutput:     Path to where we will output the data.
%
%   Output:
%   - sequence:  Built sequence.

%% step 1
% dof 6 linear registration of the brain volume output in the previous
% pipeline
step1Params = struct();
step1Config = config.step1;
step1Params.inputVolume = sprintf('%s_T1w_brain_trim.nii.gz', subjectName);
step1Params.referenceVolume = 'ch2bet.nii.gz';
step1Params.outputVolume = sprintf('%s_T1w_brain_dof6.nii.gz', subjectName);
step1Params.outputMatrix = sprintf('%s_T1w2MNI_dof6.mat', subjectName);
deps1 = { step1Params.inputVolume, step1Params.referenceVolume };
outputs1 = { step1Params.outputMatrix, step1Params.outputVolume };
step1 = Step(@PerformLinearImageRegistration, ...
             step1Params, ...
             deps1, ...
             step1Config, ...
             outputs1);


%% step 2
% apply the result of step 1 dof 6 to the bias-corrected t1 input file
step2Params = struct();
step2Config = config.step2;
step2Params.inputVolume = sprintf('T1_biascorr.nii.gz', subjectName);
step2Params.referenceVolume = 'ch2bet.nii.gz';
step2Params.outputVolume = sprintf('%s_T1w_dof6.nii.gz', subjectName);
step2Params.initMatrix = sprintf('%s_T1w2MNI_dof6.mat', subjectName);
deps2 = { step2Params.inputVolume, ...
          step2Params.referenceVolume, ...
          step2Params.initMatrix };
outputs2 = { step2Params.outputVolume };
step2 = Step(@PerformLinearImageRegistration, ...
             step2Params, ...
             deps2, ...
             step2Config, ...
             outputs2);


%% step 3
% find inverse matrix of transformation dof 6 matrix
step3Params = struct();
step3Config = config.step3;
step3Params.inputMatrix = sprintf('%s_T1w2MNI_dof6.mat', subjectName);
step3Params.outputMatrix = sprintf('%s_MNI2T1w_dof6.mat', subjectName);
deps3 = { step3Params.inputMatrix };
outputs3 = { step3Params.outputMatrix };
step3 = Step(@InvertTransformationMatrix, ...
             step3Params, ...
             deps3, ...
             step3Config, ...
             outputs3);


%% step 4
% do a dof 12 linear registration of the dof 6 brain volume
step4Params = struct();
step4Config = config.step4;
step4Params.inputVolume = sprintf('%s_T1w_brain_dof6.nii.gz', subjectName);
step4Params.referenceVolume = 'ch2bet.nii.gz';
step4Params.outputVolume = sprintf('%s_T1w_brain_dof12.nii.gz', subjectName);
step4Params.outputMatrix = sprintf('%s_T1w2MNI_dof12.mat', subjectName);
deps4 = { step4Params.inputVolume, step4Params.referenceVolume };
outputs4 = { step4Params.outputMatrix, step4Params.outputVolume };
step4 = Step(@PerformLinearImageRegistration, ...
             step4Params, ...
             deps4, ...
             step4Config, ...
             outputs4);


%% step 5
% apply the result of step 4 dof 12 to the dof 6 t1 volume
step5Params = struct();
step5Config = config.step5;
step5Params.inputVolume = sprintf('%s_T1w_dof6.nii.gz', subjectName);
step5Params.referenceVolume = 'ch2bet.nii.gz';
step5Params.outputVolume = sprintf('%s_T1w_dof12.nii.gz', subjectName);
step5Params.initMatrix = sprintf('%s_T1w2MNI_dof12.mat', subjectName);
deps5 = { step5Params.inputVolume, ...
          step5Params.referenceVolume, ...
          step5Params.initMatrix };
outputs5 = { step5Params.outputVolume };
step5 = Step(@PerformLinearImageRegistration, ...
             step5Params, ...
             deps5, ...
             step5Config, ...
             outputs5);

%% step 6
% find inverse matrix of transformation dof 12 matrix
step6Params = struct();
step6Config = config.step6;
step6Params.inputMatrix = sprintf('%s_T1w2MNI_dof12.mat', subjectName);
step6Params.outputMatrix = sprintf('%s_MNI2T1w_dof12.mat', subjectName);
deps6 = { step6Params.inputMatrix };
outputs6 = { step6Params.outputMatrix };
step6 = Step(@InvertTransformationMatrix, ...
             step6Params, ...
             deps6, ...
             step6Config, ...
             outputs6);

%% step 7
% non-linear registration of the dof 12 t1 volume
step7Params = struct();
step7Config = config.step7;
step7Params.inputImage = sprintf('%s_T1w_dof12.nii.gz', subjectName);
step7Params.referenceImage = 'ch2.nii.gz';
step7Params.outputImage = sprintf('%s_T1w_warped.nii.gz', subjectName);
step7Params.outputFieldCoefficients = sprintf('%s_T1w2MNI_warp.nii.gz', subjectName);
deps7 = { step7Params.inputImage, step7Params.referenceImage };
outputs7 = { step7Params.outputImage, step7Params.outputFieldCoefficients };
step7 = Step(@PerformNonLinearImageRegistration, ...
             step7Params, ...
             deps7, ...
             step7Config, ...
             outputs7);

%% step 8
% invwarp
step8Params = struct();
step8Config = config.step8;
step8Params.warpVolume = sprintf('%s_T1w2MNI_warp.nii.gz', subjectName);
step8Params.referenceVolume = sprintf('%s_T1w_dof12.nii.gz', subjectName);
step8Params.outputVolume = sprintf('%s_MNI2T1w_warp.nii.gz', subjectName);
deps8 = { step8Params.warpVolume, step8Params.referenceVolume };
outputs8 = { step8Params.outputVolume };
step8 = Step(@InvertWarp, ...
             step8Params, ...
             deps8, ...
             step8Config, ...
             outputs8);


%% prepare the sequence
% set up steps in order
steps = { step1, ...
          step2, ...
          step3, ...
          step4, ...
          step5, ...
          step6, ...
          step7, ...
          step8 };

% these files will be copied from the workspace to the output path
outputs = { sprintf('%s_T1w_brain_dof6.nii.gz', subjectName)  ...
            sprintf('%s_T1w_dof6.nii.gz', subjectName)  ...
            sprintf('%s_MNI2T1w_dof6.mat', subjectName) ...
            sprintf('%s_T1w2MNI_dof6.mat', subjectName) ...
            sprintf('%s_T1w_brain_dof12.nii.gz', subjectName)  ...
            sprintf('%s_T1w_dof12.nii.gz', subjectName)  ...
            sprintf('%s_T1w2MNI_dof12.mat', subjectName) ...
            step6Params.outputMatrix ...
            step7Params.outputImage ...
            step7Params.outputFieldCoefficients ...
            step8Params.outputVolume };

sequence = Sequence(steps, ...
                    inputs, ...
                    outputs, ...
                    pathToWorkspace, ...
                    pathToOutput, ...
                    config.sequence);

end
