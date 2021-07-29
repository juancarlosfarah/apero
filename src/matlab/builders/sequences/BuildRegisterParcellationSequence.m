function [sequence] = BuildRegisterParcellationSequence(inputs, ...
                                                        subjectName, ...
                                                        pathToWorkspace, ...
                                                        pathToOutput, ...
                                                        config)
%BUILDREGISTERPARCELLATIONSEQUENCE Example of a sequence builder.
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
% do a dof 6 linear registration of the brain image output in the previous
% pipeline
step1Params = {};
step1Config = config.step1;
step1Params.inputVolume = sprintf('%s_T1w_brain_mul.nii.gz', subjectName);
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
% apply the result of step 1 dof 6 to original t1 input file
step2Params = {};
step2Config = config.step2;
step2Params.inputVolume = sprintf('%s_T1w.nii.gz', subjectName);
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
step3Params = {};
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
% do a dof 12 linear registration of the brain image output in the previous
% pipeline
step4Params = {};
step4Config = config.step4;
step4Params.inputVolume = sprintf('%s_T1w_brain_mul.nii.gz', subjectName);
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
% apply the result of step 4 dof 12 to original t1 input file
step5Params = {};
step5Config = config.step5;
step5Params.inputVolume = sprintf('%s_T1w.nii.gz', subjectName);
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
step6Params = {};
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
% fnirt
step7Params = {};
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
step8Params = {};
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

%% step 9
% dilate parcellation
step9Params = {};
step9Config = config.step9;
step9Params.inputVolume = 'schaefer_2018_400_subc.nii';
step9Params.outputVolume = 'schaefer_2018_400_subc_dil.nii.gz';
deps9 = { step9Params.inputVolume };
outputs9 = { step9Params.outputVolume };
step9 = Step(@Dilate, ...
             step9Params, ...
             deps9, ...
             step9Config, ...
             outputs9);

%% step 10
% apply inverse warp to parcellation to go down to dof 12
step10Params = {};
step10Config = config.step10;
step10Params.inputVolume = 'schaefer_2018_400_subc_dil.nii.gz';
step10Params.referenceVolume = sprintf('%s_T1w_brain_dof12.nii.gz', subjectName);
step10Params.warpVolume = sprintf('%s_MNI2T1w_warp.nii.gz', subjectName);
step10Params.outputVolume = 'schaefer_2018_400_subc_invwarp.nii.gz';
deps10 = { step10Params.inputVolume, ...
           step10Params.referenceVolume,  ...
           step10Params.warpVolume };
outputs10 = { step10Params.outputVolume };
step10 = Step(@ApplyWarp, ...
              step10Params, ...
              deps10, ...
              step10Config, ...
              outputs10);
            
%% step 11
% apply inverted dof 12 transform to parcellation to go down to dof 6
step11Params = {};
step11Config = config.step11;
step11Params.inputVolume = 'schaefer_2018_400_subc_invwarp.nii.gz';
step11Params.referenceVolume = sprintf('%s_T1w_brain_dof6.nii.gz', subjectName);
step11Params.initMatrix = sprintf('%s_MNI2T1w_dof12.mat', subjectName);
step11Params.outputVolume = 'schaefer_2018_400_subc_invdof12.nii.gz';
deps11 = { step11Params.inputVolume, ...
           step11Params.referenceVolume,  ...
           step11Params.initMatrix };
outputs11 = { step11Params.outputVolume };
step11 = Step(@PerformLinearImageRegistration, ...
              step11Params, ...
              deps11, ...
              step11Config, ...
              outputs11);

%% step 12
% apply inverted dof 6 transform to parcellation to go down to native
step12Params = {};
step12Config = config.step12;
step12Params.inputVolume = 'schaefer_2018_400_subc_invdof12.nii.gz';
step12Params.referenceVolume = sprintf('%s_T1w_brain_mul.nii.gz', subjectName);
step12Params.initMatrix = sprintf('%s_MNI2T1w_dof6.mat', subjectName);
step12Params.outputVolume = 'schaefer_2018_400_subc_invdof6.nii.gz';
deps12 = { step12Params.inputVolume, ...
           step12Params.referenceVolume,  ...
           step12Params.initMatrix };
outputs12 = { step12Params.outputVolume };
step12 = Step(@PerformLinearImageRegistration, ...
              step12Params, ...
              deps12, ...
              step12Config, ...
              outputs12);
           
%% prepare the sequence
% set up steps in order
steps = { step1, ...
          step2, ...
          step3, ...
          step4, ...
          step5, ...
          step6, ...
          step7, ...
          step8, ...
          step9, ...
          step10, ...
          step11, ...
          step12 };

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
            step8Params.outputVolume, ...
            step9Params.outputVolume };

sequence = Sequence(steps, ...
                    inputs, ...
                    outputs, ...
                    pathToWorkspace, ...
                    pathToOutput, ...
                    true);

end
