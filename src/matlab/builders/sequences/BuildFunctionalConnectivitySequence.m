function [sequence] = BuildFunctionalConnectivitySequence(inputs, ...
                                                          subjectName, ...
                                                          run, ...
                                                          pathToWorkspace, ...
                                                          pathToOutput, ...
                                                          config)
%BUILDFUNCTIONALCONNECTIVITYSEQUENCE Example of a sequence builder.
%   This builder creates the typical sequence to generate functional
%   connectomes.
%
%   Input:
%   - inputs:           Inputs that will be copied into the workspace.
%   - pathToWorkspace:  Path to the sequence's workspace.
%   - pathToOutput:     Path to where we will output the data.
%
%   Output:
%   - sequence:  Built sequence.

%% step 1
% reorient to standard
step1Params = struct();
step1Config = config.step1;
step1Params.inputVolume = sprintf('%s_task-convers_%s_bold.nii.gz', ...
                                  subjectName, ...
                                  run);
% short filename a bit for succinctness 
step1Params.outputVolume = sprintf('%s_%s_std.nii.gz', ...
                                   subjectName, ...
                                   run);
deps1 = { step1Params.inputVolume };
outputs1 = { step1Params.outputVolume };
step1 = Step(@ReorientToStandard, ...
             step1Params, ...
             deps1, ...
             step1Config, ...
             outputs1);

%% step 2
% correct slice timing
step2Params = struct();
step2Config = config.step2;
step2Params.inputVolume = step1Params.outputVolume;
step2Params.outputVolume = sprintf('%s_%s_stc.nii.gz', ...
                                   subjectName, ...
                                   run);
deps2 = { step2Params.inputVolume };
outputs2 = { step2Params.outputVolume };
step2 = Step(@CorrectSliceTiming, ...
             step2Params, ...
             deps2, ...
             step2Config, ...
             outputs2);

%% step 3
% extract brain
step3Params = struct();
step3Config = config.step3;
step3Params.inputVolume = step2Params.outputVolume;
step3Params.outputVolume = sprintf('%s_%s_brain.nii.gz', ...
                                   subjectName, ...
                                   run);
% step also outputs a mask
step3OutputMask = sprintf('%s_%s_brain_mask.nii.gz', ...
                          subjectName, ...
                          run);
deps3 = { step3Params.inputVolume };
outputs3 = { step3Params.outputVolume, step3OutputMask };
step3 = Step(@ExtractBrain, ...
             step3Params, ...
             deps3, ...
             step3Config, ...
             outputs3);
           
%% step 4
% correct motion
step4Params = struct();
step4Config = config.step4;
step4Params.inputVolume = step3Params.outputVolume;
step4Params.outputVolume = sprintf('%s_%s_mcf.nii.gz', ...
                                   subjectName, ...
                                   run);
step4Config.regressorsFile = sprintf('%s_%s_motion.mat', ...
                                     subjectName, ...
                                     run);
deps4 = { step4Params.inputVolume };
outputs4 = { step4Params.outputVolume, step4Config.regressorsFile };
step4 = Step(@CorrectMotion, ...
             step4Params, ...
             deps4, ...
             step4Config, ...
             outputs4);
           

%% t1 registration to fmri space
% small r means "registered in fMRI space"

%% step 5
% compute mean volume
step5Params = struct();
step5Config = config.step5;
% motion-corrected volume
step5Params.inputVolume = step4Params.outputVolume;
step5Params.outputVolume = sprintf('%s_%s_meanvol.nii.gz', ...
                                   subjectName, ...
                                   run);
deps5 = { step5Params.inputVolume };
outputs5 = { step5Params.outputVolume };
step5 = Step(@ComputeMeanVolume, ...
             step5Params, ...
             deps5, ...
             step5Config, ...
             outputs5);
          
%% step 6
% extract brain from meanvol
step6Params = struct();
step6Config = config.step6;
step6Params.inputVolume = step5Params.outputVolume;
step6Params.outputVolume = sprintf('%s_%s_meanvol_brain.nii.gz', ...
                                   subjectName, ...
                                   run);
% step also outputs a mask
step6OutputMask = sprintf('%s_%s_meanvol_brain_mask.nii.gz', ...
                          subjectName, ...
                          run);
deps6 = { step6Params.inputVolume };
outputs6 = { step6Params.outputVolume, step6OutputMask };
step6 = Step(@ExtractBrain, ...
             step6Params, ...
             deps6, ...
             step6Config, ...
             outputs6);

%% step 7
% apply mask
step7Params = struct();
step7Config = config.step7;
% motion-corrected volume
step7Params.inputVolume = step4Params.outputVolume;
% output by step 6
step7Params.maskVolume = step6OutputMask;
step7Params.outputVolume = sprintf('%s_%s_brain_trim.nii.gz', ...
                                   subjectName, ...
                                   run);
deps7 = { step7Params.inputVolume, step7Params.maskVolume };
outputs7 = { step7Params.outputVolume };
step7 = Step(@ApplyMask, ...
             step7Params, ...
             deps7, ...
             step7Config, ...
             outputs7);

%% step 8
% perform linear image registration of t1 to fmri
step8Params = struct();
step8Config = config.step8;
step8Params.inputVolume = sprintf('%s_T1w_brain_trim.nii.gz', subjectName);
% brain-extracted mean volume
step8Params.referenceVolume = step6Params.outputVolume;
step8Params.outputMatrix = sprintf('%s_%s_T1_fmri_dof6.mat', ...
                                   subjectName, ...
                                   run);
step8Params.outputVolume = sprintf('%s_%s_rT1_brain_dof6.nii.gz', ...
                                   subjectName, ...
                                   run);
deps8 = { step8Params.inputVolume, step8Params.referenceVolume };
outputs8 = { step8Params.outputVolume, step8Params.outputMatrix };
step8 = Step(@PerformLinearImageRegistration, ...
             step8Params, ...
             deps8, ...
             step8Config, ...
             outputs8);
           
%% step 9
% apply linear transformation to wm mask
step9Params = struct();
step9Config = config.step9;
step9Params.inputVolume = 'T1w_wm_mask.nii.gz';
% brain-extracted mean volume
step9Params.referenceVolume = step6Params.outputVolume;
% dof6 output matrix
step9Params.initMatrix = step8Params.outputMatrix;
step9Params.outputVolume = sprintf('%s_%s_rT1_wm_mask_dof6.nii.gz', ...
                                   subjectName, ...
                                   run);
deps9 = { step9Params.inputVolume, ...
          step9Params.initMatrix, ...
          step9Params.referenceVolume };
outputs9 = { step9Params.outputVolume };
step9 = Step(@PerformLinearImageRegistration, ...
             step9Params, ...
             deps9, ...
             step9Config, ...
             outputs9);

%% step 10
% perform boundary-based registration of fmri to t1
step10Params = struct();
step10Config = config.step10;
% brain-extracted mean volume
step10Params.inputVolume = step6Params.outputVolume;
% dof6 registered volume
step10Params.referenceVolume = step8Params.outputVolume;
% transformed wm mask
step10Config.wmseg = step9Params.outputVolume;
step10Params.outputVolume = sprintf('%s_%s_fmri_T1_bbr.nii.gz', ...
                                    subjectName, ...
                                    run);
step10Params.outputMatrix = sprintf('%s_%s_fmri_T1_bbr.mat', ...
                                    subjectName, ...
                                    run);
deps10 = { step10Params.inputVolume, ...
           step10Params.referenceVolume, ...
           step10Config.wmseg };
outputs10 = { step10Params.outputMatrix };
step10 = Step(@PerformLinearImageRegistration, ...
              step10Params, ...
              deps10, ...
              step10Config, ...
              outputs10);

%% step 11
% invert transformation matrix
step11Params = struct();
step11Config = config.step11;
% output of bbr
step11Params.inputMatrix = step10Params.outputMatrix;
step11Params.outputMatrix = sprintf('%s_%s_T1_fmri_bbr.mat', ...
                                    subjectName, ...
                                    run);
deps11 = { step11Params.inputMatrix };
outputs11 = { step11Params.outputMatrix };
step11 = Step(@InvertTransformationMatrix, ...
              step11Params, ...
              deps11, ...
              step11Config, ...
              outputs11);

%% step 12 
% concatenate two transforms
step12Params = struct();
step12Config = config.step12;
% output of dof6
step12Params.inputMatrix1 = step8Params.outputMatrix;
% inverted output of bbr
step12Params.inputMatrix2 = step11Params.outputMatrix;
step12Params.outputMatrix = sprintf('%s_%s_T1_fmri_dof6_bbr.mat', ...
                                    subjectName, ...
                                    run);
deps12 = { step12Params.inputMatrix1, step12Params.inputMatrix2 };
outputs12 = { step12Params.outputMatrix };
step12 = Step(@ConcatenateTransformationMatrices, ...
              step12Params, ...
              deps12, ...
              step12Config, ...
              outputs12);

%% step 13
% apply linear transformation to brain mask
step13Params = struct();
step13Config = config.step13;
step13Params.inputVolume = sprintf('%s_T1w_brain_mask_filled.nii.gz', ...
                                   subjectName);
% mean volume
step13Params.referenceVolume = step6Params.outputVolume;
% dof6 bbr concatenated matrix
step13Params.initMatrix = step12Params.outputMatrix;
step13Params.outputVolume = sprintf('%s_%s_rT1_brain_mask.nii.gz', ...
                                   subjectName, ...
                                   run);
deps13 = { step13Params.inputVolume, ...
           step13Params.initMatrix, ...
           step13Params.referenceVolume };
outputs13 = { step13Params.outputVolume };
step13 = Step(@PerformLinearImageRegistration, ...
              step13Params, ...
              deps13, ...
              step13Config, ...
              outputs13);

%% step 14
% apply linear transformation to wm mask
step14Params = struct();
step14Config = config.step14;
step14Params.inputVolume = 'T1w_wm_mask.nii.gz';
% mean volume
step14Params.referenceVolume = step6Params.outputVolume;
% dof6 bbr concatenated matrix
step14Params.initMatrix = step12Params.outputMatrix;
step14Params.outputVolume = sprintf('%s_%s_rT1_wm_mask.nii.gz', ...
                                   subjectName, ...
                                   run);
deps14 = { step14Params.inputVolume, ...
           step14Params.initMatrix, ...
           step14Params.referenceVolume };
outputs14 = { step14Params.outputVolume };
step14 = Step(@PerformLinearImageRegistration, ...
              step14Params, ...
              deps14, ...
              step14Config, ...
              outputs14);

%% step 15
% apply linear transformation to wm mask eroded
step15Params = struct();
step15Config = config.step15;
step15Params.inputVolume = 'T1w_wm_mask_ero.nii.gz';
% mean volume
step15Params.referenceVolume = step6Params.outputVolume;
% dof6 bbr concatenated matrix
step15Params.initMatrix = step12Params.outputMatrix;
step15Params.outputVolume = sprintf('%s_%s_rT1_wm_mask_ero.nii.gz', ...
                                   subjectName, ...
                                   run);
deps15 = { step15Params.inputVolume, ...
           step15Params.initMatrix, ...
           step15Params.referenceVolume };
outputs15 = { step15Params.outputVolume };
step15 = Step(@PerformLinearImageRegistration, ...
              step15Params, ...
              deps15, ...
              step15Config, ...
              outputs15);

%% step 16
% apply linear transformation to csf mask
step16Params = struct();
step16Config = config.step16;
step16Params.inputVolume = 'T1w_csf_mask.nii.gz';
% mean volume
step16Params.referenceVolume = step6Params.outputVolume;
% dof6 bbr concatenated matrix
step16Params.initMatrix = step12Params.outputMatrix;
step16Params.outputVolume = sprintf('%s_%s_rT1_csf_mask.nii.gz', ...
                                   subjectName, ...
                                   run);
deps16 = { step16Params.inputVolume, ...
           step16Params.initMatrix, ...
           step16Params.referenceVolume };
outputs16 = { step16Params.outputVolume };
step16 = Step(@PerformLinearImageRegistration, ...
              step16Params, ...
              deps16, ...
              step16Config, ...
              outputs16);

%% step 17
% apply linear transformation to csf mask eroded
step17Params = struct();
step17Config = config.step17;
step17Params.inputVolume = 'T1w_csf_mask_ero.nii.gz';
% mean volume
step17Params.referenceVolume = step6Params.outputVolume;
% dof6 bbr concatenated matrix
step17Params.initMatrix = step12Params.outputMatrix;
step17Params.outputVolume = sprintf('%s_%s_rT1_csf_mask_ero.nii.gz', ...
                                   subjectName, ...
                                   run);
deps17 = { step17Params.inputVolume, ...
           step17Params.initMatrix, ...
           step17Params.referenceVolume };
outputs17 = { step17Params.outputVolume };
step17 = Step(@PerformLinearImageRegistration, ...
              step17Params, ...
              deps17, ...
              step17Config, ...
              outputs17);

%% step 18
% apply linear transformation to csfvent mask eroded
step18Params = struct();
step18Config = config.step18;
step18Params.inputVolume = 'T1w_csfvent_mask_ero.nii.gz';
% mean volume
step18Params.referenceVolume = step6Params.outputVolume;
% dof6 bbr concatenated matrix
step18Params.initMatrix = step12Params.outputMatrix;
step18Params.outputVolume = sprintf('%s_%s_rT1_csfvent_mask_ero.nii.gz', ...
                                    subjectName, ...
                                    run);
deps18 = { step18Params.inputVolume, ...
           step18Params.initMatrix, ...
           step18Params.referenceVolume };
outputs18 = { step18Params.outputVolume };
step18 = Step(@PerformLinearImageRegistration, ...
              step18Params, ...
              deps18, ...
              step18Config, ...
              outputs18);
            
%% step 19
% apply linear transformation to gm mask
step19Params = struct();
step19Config = config.step19;
step19Params.inputVolume = 'T1w_gm_mask.nii.gz';
% mean volume
step19Params.referenceVolume = step6Params.outputVolume;
% dof6 bbr concatenated matrix
step19Params.initMatrix = step12Params.outputMatrix;
step19Params.outputVolume = sprintf('%s_%s_rT1_gm_mask.nii.gz', ...
                                   subjectName, ...
                                   run);
deps19 = { step19Params.inputVolume, ...
           step19Params.initMatrix, ...
           step19Params.referenceVolume };
outputs19 = { step19Params.outputVolume };
step19 = Step(@PerformLinearImageRegistration, ...
              step19Params, ...
              deps19, ...
              step19Config, ...
              outputs19);

%% step 20
% apply linear transformation to gm parc
step20Params = struct();
step20Config = config.step20;
step20Params.inputVolume = sprintf('%s_T1w_gm_parc.nii.gz', subjectName);
% mean volume
step20Params.referenceVolume = step6Params.outputVolume;
% dof6 bbr concatenated matrix
step20Params.initMatrix = step12Params.outputMatrix;
step20Params.outputVolume = sprintf('%s_%s_rT1_gm_parc.nii.gz', ...
                                   subjectName, ...
                                   run);
deps20 = { step20Params.inputVolume, ...
           step20Params.initMatrix, ...
           step20Params.referenceVolume };
outputs20 = { step20Params.outputVolume };
step20 = Step(@PerformLinearImageRegistration, ...
              step20Params, ...
              deps20, ...
              step20Config, ...
              outputs20);

%% step 21
% apply gm mask to parcellation
step21Params = struct();
step21Config = config.step21;
% transformed gm parcellation
step21Params.inputVolume = step20Params.outputVolume;
% transformed gm mask
step21Params.maskVolume = step19Params.outputVolume;
step21Params.outputVolume = sprintf('%s_%s_rT1_gm_parc_trim.nii.gz', ...
                                    subjectName, ...
                                    run);
deps21 = { step21Params.inputVolume, step21Params.maskVolume };
outputs21 = { step21Params.outputVolume };
step21 = Step(@ApplyMask, ...
              step21Params, ...
              deps21, ...
              step21Config, ...
              outputs21);

%% step 22
% remove small clusters
step22Params = struct();
step22Config = config.step22;
% transformed gm parcellation
step22Params.inputVolume = step21Params.outputVolume;
step22Params.outputVolume = sprintf('%s_%s_rT1_gm_parc_thr.nii.gz', ...
                                    subjectName, ...
                                    run);
deps22 = { step22Params.inputVolume };
outputs22 = { step22Params.outputVolume };
step22 = Step(@ThresholdClusters, ...
              step22Params, ...
              deps22, ...
              step22Config, ...
              outputs22);
            
%% step 23
% normalize intensity
step23Params = struct();
step23Config = config.step23;
% trimmed brain
step23Params.inputVolume = step7Params.outputVolume;
step23Params.outputVolume = sprintf('%s_%s_brain_norm.nii.gz', ...
                                    subjectName, ...
                                    run);
deps23 = { step23Params.inputVolume };
outputs23 = { step23Params.outputVolume };
step23 = Step(@NormalizeIntensity, ...
              step23Params, ...
              deps23, ...
              step23Config, ...
              outputs23);

%% step 24
% fill brain mask
step24Params = struct();
step24Config = config.step24;
% transformed brain mask
step24Params.inputVolume = step13Params.outputVolume;
% mask output by brain extraction of mean volume
step24Params.referenceVolume = step6OutputMask;
step24Params.outputVolume = sprintf('%s_%s_brain_mask_fill.nii.gz', ...
                                    subjectName, ...
                                    run);
deps24 = { step24Params.inputVolume };
outputs24 = { step24Params.outputVolume };
step24 = Step(@FillBrainMask, ...
              step24Params, ...
              deps24, ...
              step24Config, ...
              outputs24);
            
%% step 25
% detrend
step25Params = struct();
step25Config = config.step25;
% normalized brain
step25Params.inputVolume = step23Params.outputVolume;
% filled brain mask
step25Params.maskVolume = step24Params.outputVolume;
step25Params.outputVolume = sprintf('%s_%s_brain_mask_detrend.nii.gz', ...
                                    subjectName, ...
                                    run);
deps25 = { step25Params.inputVolume };
outputs25 = { step25Params.outputVolume };
step25 = Step(@Detrend, ...
              step25Params, ...
              deps25, ...
              step25Config, ...
              outputs25);

%% outlier detection


%% step 26
% framewise displacement regressor
step26Params = struct();
step26Config = config.step26;
% input is currently result after slice-timing correction because this
% need to be run on the "raw" data, i.e., before motion correction
step26Params.inputVolume = step2Params.outputVolume;
step26Params.outputPath = sprintf('%s_%s_motion-regressors', ...
                                  subjectName, ...
                                  run);
step26OutliersOutputFile = sprintf('%s/%s', ...
                                   step26Params.outputPath, ...
                                   sprintf('motionOutliers_%s.mat', ...
                                           step26Config.metric));
% note: there are also other output files

% first brain extraction brain mask
step26Params.maskVolume = step3OutputMask;

deps26 = { step26Params.inputVolume };
outputs26 = { step26Params.outputPath, step26OutliersOutputFile };
step26 = Step(@DetectMotionOutliers, ...
              step26Params, ...
              deps26, ...
              step26Config, ...
              outputs26);
            
%% step 27
% dvars regressor
step27Params = struct();
step27Config = config.step27;
% input is currently result after slice-timing correction because this
% need to be run on the "raw" data, i.e., before motion correction
step27Params.inputVolume = step2Params.outputVolume;
step27Params.outputPath = sprintf('%s_%s_motion-regressors', ...
                                  subjectName, ...
                                  run);
step27OutliersOutputFile = sprintf('%s/%s', ...
                                   step27Params.outputPath, ...
                                   sprintf('motionOutliers_%s.mat', ...
                                           step27Config.metric));
% note: there are also other output files

% first brain extraction brain mask
step27Params.maskVolume = step3OutputMask;

deps27 = { step27Params.inputVolume };
outputs27 = { step27Params.outputPath, step27OutliersOutputFile };
step27 = Step(@DetectMotionOutliers, ...
              step27Params, ...
              deps27, ...
              step27Config, ...
              outputs27);

%% step 28
% std dev outliers
step28Params = struct();
step28Config = config.step28;
% input is currently after motion correction for this outlier detection
% to account for outliers even after running the motion correct step, as
% opposed to the fd and dvars metrics that are run on the "raw" data
step28Params.inputVolume = step4Params.outputVolume;
step28Params.outputFile = sprintf('%s_%s_std-dev_regressors.txt', ...
                                  subjectName, ...
                                  run);
step28Params.outputOutliers = sprintf('%s_%s_std-dev_outliers.mat', ...
                                  subjectName, ...
                                  run);

deps28 = { step28Params.inputVolume };
outputs28 = { step28Params.outputFile, step28Params.outputOutliers };
step28 = Step(@DetectStdDevOutliers, ...
              step28Params, ...
              deps28, ...
              step28Config, ...
              outputs28);
            
%% step 29
% csf vent pca
step29Params = struct();
step29Config = config.step29;
% csf vent mask eroded
% we use csfvent because we do not want to regress out other signals and
% the signal from vent is "deeper" than from csf
step29Params.maskVolume = step18Params.outputVolume;
% brain output from detrend
step29Params.brainVolume = step25Params.outputVolume;
step29Params.outputFile = sprintf('%s_%s_pca_csfvent.mat', ...
                                  subjectName, ...
                                  run);
step29Config.regressorsOutputFile = sprintf('%s_%s_csfvent_regressors.mat', ...
                                            subjectName, ...
                                            run);
deps29 = { step29Params.maskVolume, step29Params.brainVolume };
outputs29 = { step29Params.outputFile, step29Config.regressorsOutputFile };
step29 = Step(@PerformDimensionalityAnalysis, ...
              step29Params, ...
              deps29, ...
              step29Config, ...
              outputs29);
            
%% step 30
% wm pca
step30Params = struct();
step30Config = config.step30;
% wm mask eroded
step30Params.maskVolume = step15Params.outputVolume;
% brain output from detrend
step30Params.brainVolume = step25Params.outputVolume;
step30Params.outputFile = sprintf('%s_%s_pca_wm.mat', ...
                                  subjectName, ...
                                  run);
step30Config.regressorsOutputFile = sprintf('%s_%s_wm_regressors.mat', ...
                                            subjectName, ...
                                            run);
deps30 = { step30Params.maskVolume, step30Params.brainVolume };
outputs30 = { step30Params.outputFile, step30Config.regressorsOutputFile };
step30 = Step(@PerformDimensionalityAnalysis, ...
              step30Params, ...
              deps30, ...
              step30Config, ...
              outputs30);

%% step 31
% gm pca
step31Params = struct();
step31Config = config.step31;
% gm mask
step31Params.maskVolume = step21Params.outputVolume;
% brain output from detrend
step31Params.brainVolume = step25Params.outputVolume;
step31Params.outputFile = sprintf('%s_%s_pca_gm.mat', ...
                                  subjectName, ...
                                  run);
step31Config.regressorsOutputFile = sprintf('%s_%s_gm_regressors.mat', ...
                                            subjectName, ...
                                            run);
deps31 = { step31Params.maskVolume, step31Params.brainVolume };
outputs31 = { step31Params.outputFile, step31Config.regressorsOutputFile };
step31 = Step(@PerformDimensionalityAnalysis, ...
              step31Params, ...
              deps31, ...
              step31Config, ...
              outputs31);

%% step 32
% global signal pca
step32Params = struct();
step32Config = config.step32;
% brain mask filled
step32Params.maskVolume = step24Params.outputVolume;
% brain output from detrend
step32Params.brainVolume = step25Params.outputVolume;
step32Params.outputFile = sprintf('%s_%s_pca_gs.mat', ...
                                  subjectName, ...
                                  run);
step32Config.regressorsOutputFile = sprintf('%s_%s_gs_regressors.mat', ...
                                            subjectName, ...
                                            run);
deps32 = { step32Params.maskVolume, step32Params.brainVolume };
outputs32 = { step32Params.outputFile, step32Config.regressorsOutputFile };
step32 = Step(@PerformDimensionalityAnalysis, ...
              step32Params, ...
              deps32, ...
              step32Config, ...
              outputs32);

%% step 33
% perform regression
step33Params = struct();
step33Config = config.step33;
% brain mask filled
step33Params.maskVolume = step24Params.outputVolume;
% brain output from detrend
step33Params.brainVolume = step25Params.outputVolume;
step33Params.outputVolume = sprintf('%s_%s_regressed.nii.gz', ...
                                    subjectName, ...
                                    run);
step33Config.outlierFiles = { ...
  step26OutliersOutputFile, ...    % fd motion outlier
  step27OutliersOutputFile, ...    % dvars motion outlier
  step28Params.outputOutliers, ... % standard deviation outliers
};
step33Config.regressorFiles = { ...
  step4Config.regressorsFile, ...        % motion regressors
  step29Config.regressorsOutputFile, ... % csfvent regressors
  step30Config.regressorsOutputFile, ... % wm regressors
  step32Config.regressorsOutputFile, ... % gs regressors
};
step33Config.regressorsOutputFile = sprintf('%s_%s_regressors.mat', ...
                                            subjectName, ...
                                            run);
step33Config.outliersOutputFile = sprintf('%s_%s_outliers.mat', ...
                                          subjectName, ...
                                          run);
deps33 = [ step33Params.maskVolume, ...
           step33Params.brainVolume, ...
           step33Config.outlierFiles(:)', ...
           step33Config.regressorFiles(:)' ];
outputs33 = { step33Params.outputVolume, ...
              step33Config.regressorsOutputFile, ...
              step33Config.outliersOutputFile };
step33 = Step(@PerformRegression, ...
              step33Params, ...
              deps33, ...
              step33Config, ...
              outputs33);

%% step 34
% global signal time series
step34Params = struct();
step34Config = config.step34;
% brain output from regression
step34Params.brainVolume = step33Params.outputVolume;
% brain mask filled
step34Params.maskVolume = step24Params.outputVolume;
step34Params.outputFile = sprintf('%s_%s_ts_gs.mat', ...
                                  subjectName, ...
                                  run);
deps34 = { step34Params.maskVolume, step34Params.brainVolume };
outputs34 = { step34Params.outputFile };
step34 = Step(@SaveMaskedTimeSeries, ...
              step34Params, ...
              deps34, ...
              step34Config, ...
              outputs34);

%% step 35
% gray matter time series
step35Params = struct();
step35Config = config.step35;
% brain output from regression
step35Params.brainVolume = step33Params.outputVolume;
% gray matter mask
step35Params.maskVolume = step19Params.outputVolume;
step35Params.outputFile = sprintf('%s_%s_ts_gm.mat', ...
                                  subjectName, ...
                                  run);
deps35 = { step35Params.maskVolume, step35Params.brainVolume };
outputs35 = { step35Params.outputFile };
step35 = Step(@SaveMaskedTimeSeries, ...
              step35Params, ...
              deps35, ...
              step35Config, ...
              outputs35);

%% step 36
% white matter time series
step36Params = struct();
step36Config = config.step36;
% brain output from regression
step36Params.brainVolume = step33Params.outputVolume;
% white matter mask eroded
step36Params.maskVolume = step15Params.outputVolume;
step36Params.outputFile = sprintf('%s_%s_ts_wm.mat', ...
                                  subjectName, ...
                                  run);
deps36 = { step36Params.maskVolume, step36Params.brainVolume };
outputs36 = { step36Params.outputFile };
step36 = Step(@SaveMaskedTimeSeries, ...
              step36Params, ...
              deps36, ...
              step36Config, ...
              outputs36);


%% step 37
% csfvent time series
step37Params = struct();
step37Config = config.step37;
% brain output from regression
step37Params.brainVolume = step33Params.outputVolume;
% csf vent mask eroded
step37Params.maskVolume = step18Params.outputVolume;
step37Params.outputFile = sprintf('%s_%s_ts_csfvent.mat', ...
                                  subjectName, ...
                                  run);
deps37 = { step37Params.maskVolume, step37Params.brainVolume };
outputs37 = { step37Params.outputFile };
step37 = Step(@SaveMaskedTimeSeries, ...
              step37Params, ...
              deps37, ...
              step37Config, ...
              outputs37);

%% step 38
% band pass filter
step38Params = struct();
step38Config = config.step38;
% brain output from regression
step38Params.inputVolume = step33Params.outputVolume;
% gs time series
step38Params.timeSeriesFile = step34Params.outputFile;
step38Params.outputVolume = sprintf('%s_%s_bandpass.nii.gz', ...
                                    subjectName, ...
                                    run);
deps38 = { step38Params.inputVolume, step38Params.timeSeriesFile };
outputs38 = { step38Params.outputVolume };
step38 = Step(@ApplyBandPassFilter, ...
              step38Params, ...
              deps38, ...
              step38Config, ...
              outputs38);

%% step 39
% regress out pca1
step39Params = struct();
step39Config = config.step39;
% brain mask filled
step39Params.maskVolume = step24Params.outputVolume;
% brain output from regression
step39Params.brainVolume = step33Params.outputVolume;
step39Params.outputVolume = sprintf('%s_%s_pca%d.nii.gz', ...
                                    subjectName, ...
                                    run, ...
                                    step39Config.numComponents);
step39Config.pcaFiles = { ...
  step29Params.outputFile, ... % csfvent pca
  step30Params.outputFile, ... % wm pca
  step32Params.outputFile, ... % gs pca
};
deps39 = [ step39Params.maskVolume, ...
           step39Params.brainVolume, ...
           step39Config.pcaFiles(:)' ];
outputs39 = { step39Params.outputVolume };
step39 = Step(@RegressOutPca, ...
              step39Params, ...
              deps39, ...
              step39Config, ...
              outputs39);

%% step 40
% regress out pca3
step40Params = struct();
step40Config = config.step40;
% brain mask filled
step40Params.maskVolume = step24Params.outputVolume;
% brain output from regression
step40Params.brainVolume = step33Params.outputVolume;
step40Params.outputVolume = sprintf('%s_%s_pca%d.nii.gz', ...
                                    subjectName, ...
                                    run, ...
                                    step40Config.numComponents);
step40Config.pcaFiles = { ...
  step29Params.outputFile, ... % csfvent pca
  step30Params.outputFile, ... % wm pca
  step32Params.outputFile, ... % gs pca
};
deps40 = [ step40Params.maskVolume, ...
           step40Params.brainVolume, ...
           step40Config.pcaFiles(:)' ];
outputs40 = { step40Params.outputVolume };
step40 = Step(@RegressOutPca, ...
              step40Params, ...
              deps40, ...
              step40Config, ...
              outputs40);

%% step 41
% regress out pca5
step41Params = struct();
step41Config = config.step41;
% brain mask filled
step41Params.maskVolume = step24Params.outputVolume;
% brain output from regression
step41Params.brainVolume = step33Params.outputVolume;
step41Params.outputVolume = sprintf('%s_%s_pca%d.nii.gz', ...
                                    subjectName, ...
                                    run, ...
                                    step41Config.numComponents);
step41Config.pcaFiles = { ...
  step29Params.outputFile, ... % csfvent pca
  step30Params.outputFile, ... % wm pca
  step32Params.outputFile, ... % gs pca
};
deps41 = [ step41Params.maskVolume, ...
           step41Params.brainVolume, ...
           step41Config.pcaFiles(:)' ];
outputs41 = { step41Params.outputVolume };
step41 = Step(@RegressOutPca, ...
              step41Params, ...
              deps41, ...
              step41Config, ...
              outputs41);
            
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
          step12, ...
          step13, ...
          step14, ...
          step15, ...
          step16, ...
          step17, ...
          step18, ...
          step19, ...
          step20, ...
          step21, ...
          step22, ...
          step23, ...
          step24, ...
          step25, ...
          step26, ...
          step27, ...
          step28, ...
          step29, ...
          step30, ...
          step31, ...
          step32, ...
          step33, ...
          step34, ...
          step35, ...
          step36, ...
          step37, ...
          step38, ...
          step39, ...
          step40, ...
          step41 };

% these files will be copied from the workspace to the output path
% todo: add final version
outputs = { step1Params.outputVolume, ...
            step3Params.outputVolume, ...
            step3Params.outputVolume, ...
            step4Params.outputVolume, ...
            step5Params.outputVolume, ...
            step6Params.outputVolume, ...
            step7Params.outputVolume, ...
            step8Params.outputVolume, ...
            step9Params.outputVolume };

sequence = Sequence(steps, ...
                    inputs, ...
                    outputs, ...
                    pathToWorkspace, ...
                    pathToOutput, ...
                    config.sequence);

end

