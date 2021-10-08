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
step1Config = config.step1;
step1Config.inputVolume = sprintf('%s_task-convers_%s_bold.nii.gz', ...
                                  subjectName, ...
                                  run);
% short filename a bit for succinctness 
step1Config.outputVolume = sprintf('%s_%s_std.nii.gz', ...
                                   subjectName, ...
                                   run);
deps1 = { step1Config.inputVolume };
outputs1 = { step1Config.outputVolume };
step1 = Step(@ReorientToStandard, ...
             step1Config, ...
             deps1, ...
             outputs1);

%% step 2
% correct slice timing
step2Config = config.step2;
step2Config.inputVolume = step1Config.outputVolume;
step2Config.outputVolume = sprintf('%s_%s_stc.nii.gz', ...
                                   subjectName, ...
                                   run);
deps2 = { step2Config.inputVolume };
outputs2 = { step2Config.outputVolume };
step2 = Step(@CorrectSliceTiming, ...
             step2Config, ...
             deps2, ...
             outputs2);

%% step 3
% extract brain
step3Config = config.step3;
step3Config.inputVolume = step2Config.outputVolume;
step3Config.outputVolume = sprintf('%s_%s_brain.nii.gz', ...
                                   subjectName, ...
                                   run);
% step also outputs a mask
step3OutputMask = sprintf('%s_%s_brain_mask.nii.gz', ...
                          subjectName, ...
                          run);
deps3 = { step3Config.inputVolume };
outputs3 = { step3Config.outputVolume, step3OutputMask };
step3 = Step(@ExtractBrain, ...
             step3Config, ...
             deps3, ...
             outputs3);
           
%% step 4
% correct motion
step4Config = config.step4;
step4Config.inputVolume = step3Config.outputVolume;
step4Config.outputVolume = sprintf('%s_%s_mcf.nii.gz', ...
                                   subjectName, ...
                                   run);
step4Config.regressorsFile = sprintf('%s_%s_motion.mat', ...
                                     subjectName, ...
                                     run);
deps4 = { step4Config.inputVolume };
outputs4 = { step4Config.outputVolume, step4Config.regressorsFile };
step4 = Step(@CorrectMotion, ...
             step4Config, ...
             deps4, ...
             outputs4);
           

%% t1 registration to fmri space
% small r means "registered in fMRI space"

%% step 5
% compute mean volume
step5Config = config.step5;
% motion-corrected volume
step5Config.inputVolume = step4Config.outputVolume;
step5Config.outputVolume = sprintf('%s_%s_meanvol.nii.gz', ...
                                   subjectName, ...
                                   run);
deps5 = { step5Config.inputVolume };
outputs5 = { step5Config.outputVolume };
step5 = Step(@ComputeMeanVolume, ...
             step5Config, ...
             deps5, ...
             outputs5);
          
%% step 6
% extract brain from meanvol
step6Config = config.step6;
step6Config.inputVolume = step5Config.outputVolume;
step6Config.outputVolume = sprintf('%s_%s_meanvol_brain.nii.gz', ...
                                   subjectName, ...
                                   run);
% step also outputs a mask
step6OutputMask = sprintf('%s_%s_meanvol_brain_mask.nii.gz', ...
                          subjectName, ...
                          run);
deps6 = { step6Config.inputVolume };
outputs6 = { step6Config.outputVolume, step6OutputMask };
step6 = Step(@ExtractBrain, ...
             step6Config, ...
             deps6, ...
             outputs6);

%% step 7
% apply mask
step7Config = config.step7;
% motion-corrected volume
step7Config.inputVolume = step4Config.outputVolume;
% output by step 6
step7Config.maskVolume = step6OutputMask;
step7Config.outputVolume = sprintf('%s_%s_brain_trim.nii.gz', ...
                                   subjectName, ...
                                   run);
deps7 = { step7Config.inputVolume, step7Config.maskVolume };
outputs7 = { step7Config.outputVolume };
step7 = Step(@ApplyMask, ...
             step7Config, ...
             deps7, ...
             outputs7);

%% step 8
% perform linear image registration of t1 to fmri
step8Config = config.step8;
step8Config.inputVolume = sprintf('%s_T1w_brain_trim.nii.gz', subjectName);
% brain-extracted mean volume
step8Config.referenceVolume = step6Config.outputVolume;
step8Config.outputMatrix = sprintf('%s_%s_T1_fmri_dof6.mat', ...
                                   subjectName, ...
                                   run);
step8Config.outputVolume = sprintf('%s_%s_rT1_brain_dof6.nii.gz', ...
                                   subjectName, ...
                                   run);
deps8 = { step8Config.inputVolume, step8Config.referenceVolume };
outputs8 = { step8Config.outputVolume, step8Config.outputMatrix };
step8 = Step(@PerformLinearImageRegistration, ...
             step8Config, ...
             deps8, ...
             outputs8);
           
%% step 9
% apply linear transformation to wm mask
step9Config = config.step9;
step9Config.inputVolume = 'T1w_wm_mask.nii.gz';
% brain-extracted mean volume
step9Config.referenceVolume = step6Config.outputVolume;
% dof6 output matrix
step9Config.initMatrix = step8Config.outputMatrix;
step9Config.outputVolume = sprintf('%s_%s_rT1_wm_mask_dof6.nii.gz', ...
                                   subjectName, ...
                                   run);
deps9 = { step9Config.inputVolume, ...
          step9Config.initMatrix, ...
          step9Config.referenceVolume };
outputs9 = { step9Config.outputVolume };
step9 = Step(@PerformLinearImageRegistration, ...
             step9Config, ...
             deps9, ...
             outputs9);

%% step 10
% perform boundary-based registration of fmri to t1
step10Config = config.step10;
% brain-extracted mean volume
step10Config.inputVolume = step6Config.outputVolume;
% dof6 registered volume
step10Config.referenceVolume = step8Config.outputVolume;
% transformed wm mask
step10Config.wmseg = step9Config.outputVolume;
step10Config.outputVolume = sprintf('%s_%s_fmri_T1_bbr.nii.gz', ...
                                    subjectName, ...
                                    run);
step10Config.outputMatrix = sprintf('%s_%s_fmri_T1_bbr.mat', ...
                                    subjectName, ...
                                    run);
deps10 = { step10Config.inputVolume, ...
           step10Config.referenceVolume, ...
           step10Config.wmseg };
outputs10 = { step10Config.outputMatrix };
step10 = Step(@PerformLinearImageRegistration, ...
              step10Config, ...
              deps10, ...
              outputs10);

%% step 11
% invert transformation matrix
step11Config = config.step11;
% output of bbr
step11Config.inputMatrix = step10Config.outputMatrix;
step11Config.outputMatrix = sprintf('%s_%s_T1_fmri_bbr.mat', ...
                                    subjectName, ...
                                    run);
deps11 = { step11Config.inputMatrix };
outputs11 = { step11Config.outputMatrix };
step11 = Step(@InvertTransformationMatrix, ...
              step11Config, ...
              deps11, ...
              outputs11);

%% step 12 
% concatenate two transforms
step12Config = config.step12;
% output of dof6
step12Config.inputMatrix1 = step8Config.outputMatrix;
% inverted output of bbr
step12Config.inputMatrix2 = step11Config.outputMatrix;
step12Config.outputMatrix = sprintf('%s_%s_T1_fmri_dof6_bbr.mat', ...
                                    subjectName, ...
                                    run);
deps12 = { step12Config.inputMatrix1, step12Config.inputMatrix2 };
outputs12 = { step12Config.outputMatrix };
step12 = Step(@ConcatenateTransformationMatrices, ...
              step12Config, ...
              deps12, ...
              outputs12);

%% step 13
% apply linear transformation to brain mask
step13Config = config.step13;
step13Config.inputVolume = sprintf('%s_T1w_brain_mask_filled.nii.gz', ...
                                   subjectName);
% mean volume
step13Config.referenceVolume = step6Config.outputVolume;
% dof6 bbr concatenated matrix
step13Config.initMatrix = step12Config.outputMatrix;
step13Config.outputVolume = sprintf('%s_%s_rT1_brain_mask.nii.gz', ...
                                   subjectName, ...
                                   run);
deps13 = { step13Config.inputVolume, ...
           step13Config.initMatrix, ...
           step13Config.referenceVolume };
outputs13 = { step13Config.outputVolume };
step13 = Step(@PerformLinearImageRegistration, ...
              step13Config, ...
              deps13, ...
              outputs13);

%% step 14
% apply linear transformation to wm mask
step14Config = config.step14;
step14Config.inputVolume = 'T1w_wm_mask.nii.gz';
% mean volume
step14Config.referenceVolume = step6Config.outputVolume;
% dof6 bbr concatenated matrix
step14Config.initMatrix = step12Config.outputMatrix;
step14Config.outputVolume = sprintf('%s_%s_rT1_wm_mask.nii.gz', ...
                                   subjectName, ...
                                   run);
deps14 = { step14Config.inputVolume, ...
           step14Config.initMatrix, ...
           step14Config.referenceVolume };
outputs14 = { step14Config.outputVolume };
step14 = Step(@PerformLinearImageRegistration, ...
              step14Config, ...
              deps14, ...
              outputs14);

%% step 15
% apply linear transformation to wm mask eroded
step15Config = config.step15;
step15Config.inputVolume = 'T1w_wm_mask_ero.nii.gz';
% mean volume
step15Config.referenceVolume = step6Config.outputVolume;
% dof6 bbr concatenated matrix
step15Config.initMatrix = step12Config.outputMatrix;
step15Config.outputVolume = sprintf('%s_%s_rT1_wm_mask_ero.nii.gz', ...
                                   subjectName, ...
                                   run);
deps15 = { step15Config.inputVolume, ...
           step15Config.initMatrix, ...
           step15Config.referenceVolume };
outputs15 = { step15Config.outputVolume };
step15 = Step(@PerformLinearImageRegistration, ...
              step15Config, ...
              deps15, ...
              outputs15);

%% step 16
% apply linear transformation to csf mask
step16Config = config.step16;
step16Config.inputVolume = 'T1w_csf_mask.nii.gz';
% mean volume
step16Config.referenceVolume = step6Config.outputVolume;
% dof6 bbr concatenated matrix
step16Config.initMatrix = step12Config.outputMatrix;
step16Config.outputVolume = sprintf('%s_%s_rT1_csf_mask.nii.gz', ...
                                   subjectName, ...
                                   run);
deps16 = { step16Config.inputVolume, ...
           step16Config.initMatrix, ...
           step16Config.referenceVolume };
outputs16 = { step16Config.outputVolume };
step16 = Step(@PerformLinearImageRegistration, ...
              step16Config, ...
              deps16, ...
              outputs16);

%% step 17
% apply linear transformation to csf mask eroded
step17Config = config.step17;
step17Config.inputVolume = 'T1w_csf_mask_ero.nii.gz';
% mean volume
step17Config.referenceVolume = step6Config.outputVolume;
% dof6 bbr concatenated matrix
step17Config.initMatrix = step12Config.outputMatrix;
step17Config.outputVolume = sprintf('%s_%s_rT1_csf_mask_ero.nii.gz', ...
                                   subjectName, ...
                                   run);
deps17 = { step17Config.inputVolume, ...
           step17Config.initMatrix, ...
           step17Config.referenceVolume };
outputs17 = { step17Config.outputVolume };
step17 = Step(@PerformLinearImageRegistration, ...
              step17Config, ...
              deps17, ...
              outputs17);

%% step 18
% apply linear transformation to csfvent mask eroded
step18Config = config.step18;
step18Config.inputVolume = 'T1w_csfvent_mask_ero.nii.gz';
% mean volume
step18Config.referenceVolume = step6Config.outputVolume;
% dof6 bbr concatenated matrix
step18Config.initMatrix = step12Config.outputMatrix;
step18Config.outputVolume = sprintf('%s_%s_rT1_csfvent_mask_ero.nii.gz', ...
                                    subjectName, ...
                                    run);
deps18 = { step18Config.inputVolume, ...
           step18Config.initMatrix, ...
           step18Config.referenceVolume };
outputs18 = { step18Config.outputVolume };
step18 = Step(@PerformLinearImageRegistration, ...
              step18Config, ...
              deps18, ...
              outputs18);
            
%% step 19
% apply linear transformation to gm mask
step19Config = config.step19;
step19Config.inputVolume = 'T1w_gm_mask.nii.gz';
% mean volume
step19Config.referenceVolume = step6Config.outputVolume;
% dof6 bbr concatenated matrix
step19Config.initMatrix = step12Config.outputMatrix;
step19Config.outputVolume = sprintf('%s_%s_rT1_gm_mask.nii.gz', ...
                                   subjectName, ...
                                   run);
deps19 = { step19Config.inputVolume, ...
           step19Config.initMatrix, ...
           step19Config.referenceVolume };
outputs19 = { step19Config.outputVolume };
step19 = Step(@PerformLinearImageRegistration, ...
              step19Config, ...
              deps19, ...
              outputs19);

%% step 20
% apply linear transformation to gm parc
step20Config = config.step20;
step20Config.inputVolume = sprintf('%s_T1w_gm_parc.nii.gz', subjectName);
% mean volume
step20Config.referenceVolume = step6Config.outputVolume;
% dof6 bbr concatenated matrix
step20Config.initMatrix = step12Config.outputMatrix;
step20Config.outputVolume = sprintf('%s_%s_rT1_gm_parc.nii.gz', ...
                                   subjectName, ...
                                   run);
deps20 = { step20Config.inputVolume, ...
           step20Config.initMatrix, ...
           step20Config.referenceVolume };
outputs20 = { step20Config.outputVolume };
step20 = Step(@PerformLinearImageRegistration, ...
              step20Config, ...
              deps20, ...
              outputs20);

%% step 21
% apply gm mask to parcellation
step21Config = config.step21;
% transformed gm parcellation
step21Config.inputVolume = step20Config.outputVolume;
% transformed gm mask
step21Config.maskVolume = step19Config.outputVolume;
step21Config.outputVolume = sprintf('%s_%s_rT1_gm_parc_trim.nii.gz', ...
                                    subjectName, ...
                                    run);
deps21 = { step21Config.inputVolume, step21Config.maskVolume };
outputs21 = { step21Config.outputVolume };
step21 = Step(@ApplyMask, ...
              step21Config, ...
              deps21, ...
              outputs21);

%% step 22
% remove small clusters
step22Config = config.step22;
% transformed gm parcellation
step22Config.inputVolume = step21Config.outputVolume;
step22Config.outputVolume = sprintf('%s_%s_rT1_gm_parc_thr.nii.gz', ...
                                    subjectName, ...
                                    run);
deps22 = { step22Config.inputVolume };
outputs22 = { step22Config.outputVolume };
step22 = Step(@ThresholdClusters, ...
              step22Config, ...
              deps22, ...
              outputs22);
            
%% step 23
% normalize intensity
step23Config = config.step23;
% trimmed brain
step23Config.inputVolume = step7Config.outputVolume;
step23Config.outputVolume = sprintf('%s_%s_brain_norm.nii.gz', ...
                                    subjectName, ...
                                    run);
deps23 = { step23Config.inputVolume };
outputs23 = { step23Config.outputVolume };
step23 = Step(@NormalizeIntensity, ...
              step23Config, ...
              deps23, ...
              outputs23);

%% step 24
% fill brain mask
step24Config = config.step24;
% transformed brain mask
step24Config.inputVolume = step13Config.outputVolume;
% mask output by brain extraction of mean volume
step24Config.referenceVolume = step6OutputMask;
step24Config.outputVolume = sprintf('%s_%s_brain_mask_fill.nii.gz', ...
                                    subjectName, ...
                                    run);
deps24 = { step24Config.inputVolume };
outputs24 = { step24Config.outputVolume };
step24 = Step(@FillBrainMask, ...
              step24Config, ...
              deps24, ...
              outputs24);
            
%% step 25
% detrend
step25Config = config.step25;
% normalized brain
step25Config.inputVolume = step23Config.outputVolume;
% filled brain mask
step25Config.maskVolume = step24Config.outputVolume;
step25Config.outputVolume = sprintf('%s_%s_brain_mask_detrend.nii.gz', ...
                                    subjectName, ...
                                    run);
deps25 = { step25Config.inputVolume };
outputs25 = { step25Config.outputVolume };
step25 = Step(@Detrend, ...
              step25Config, ...
              deps25, ...
              outputs25);

%% outlier detection


%% step 26
% framewise displacement regressor
step26Config = config.step26;
% input is currently result after slice-timing correction because this
% need to be run on the "raw" data, i.e., before motion correction
step26Config.inputVolume = step2Config.outputVolume;
step26Config.outputPath = sprintf('%s_%s_motion-regressors', ...
                                  subjectName, ...
                                  run);
step26OutliersOutputFile = sprintf('%s/%s', ...
                                   step26Config.outputPath, ...
                                   sprintf('motionOutliers_%s.mat', ...
                                           step26Config.metric));
% note: there are also other output files

% first brain extraction brain mask
step26Config.maskVolume = step3OutputMask;

deps26 = { step26Config.inputVolume };
outputs26 = { step26Config.outputPath, step26OutliersOutputFile };
step26 = Step(@DetectMotionOutliers, ...
              step26Config, ...
              deps26, ...
              outputs26);
            
%% step 27
% dvars regressor
step27Config = config.step27;
% input is currently result after slice-timing correction because this
% need to be run on the "raw" data, i.e., before motion correction
step27Config.inputVolume = step2Config.outputVolume;
step27Config.outputPath = sprintf('%s_%s_motion-regressors', ...
                                  subjectName, ...
                                  run);
step27OutliersOutputFile = sprintf('%s/%s', ...
                                   step27Config.outputPath, ...
                                   sprintf('motionOutliers_%s.mat', ...
                                           step27Config.metric));
% note: there are also other output files

% first brain extraction brain mask
step27Config.maskVolume = step3OutputMask;

deps27 = { step27Config.inputVolume };
outputs27 = { step27Config.outputPath, step27OutliersOutputFile };
step27 = Step(@DetectMotionOutliers, ...
              step27Config, ...
              deps27, ...
              outputs27);

%% step 28
% std dev outliers
step28Config = config.step28;
% input is currently after motion correction for this outlier detection
% to account for outliers even after running the motion correct step, as
% opposed to the fd and dvars metrics that are run on the "raw" data
step28Config.inputVolume = step4Config.outputVolume;
step28Config.outputFile = sprintf('%s_%s_std-dev_regressors.txt', ...
                                  subjectName, ...
                                  run);
step28Config.outputOutliers = sprintf('%s_%s_std-dev_outliers.mat', ...
                                  subjectName, ...
                                  run);

deps28 = { step28Config.inputVolume };
outputs28 = { step28Config.outputFile, step28Config.outputOutliers };
step28 = Step(@DetectStdDevOutliers, ...
              step28Config, ...
              deps28, ...
              outputs28);
            
%% step 29
% csf vent pca
step29Config = config.step29;
% csf vent mask eroded
% we use csfvent because we do not want to regress out other signals and
% the signal from vent is "deeper" than from csf
step29Config.maskVolume = step18Config.outputVolume;
% brain output from detrend
step29Config.brainVolume = step25Config.outputVolume;
step29Config.outputFile = sprintf('%s_%s_pca_csfvent.mat', ...
                                  subjectName, ...
                                  run);
step29Config.regressorsOutputFile = sprintf('%s_%s_csfvent_regressors.mat', ...
                                            subjectName, ...
                                            run);
deps29 = { step29Config.maskVolume, step29Config.brainVolume };
outputs29 = { step29Config.outputFile, step29Config.regressorsOutputFile };
step29 = Step(@PerformDimensionalityAnalysis, ...
              step29Config, ...
              deps29, ...
              outputs29);
            
%% step 30
% wm pca
step30Config = config.step30;
% wm mask eroded
step30Config.maskVolume = step15Config.outputVolume;
% brain output from detrend
step30Config.brainVolume = step25Config.outputVolume;
step30Config.outputFile = sprintf('%s_%s_pca_wm.mat', ...
                                  subjectName, ...
                                  run);
step30Config.regressorsOutputFile = sprintf('%s_%s_wm_regressors.mat', ...
                                            subjectName, ...
                                            run);
deps30 = { step30Config.maskVolume, step30Config.brainVolume };
outputs30 = { step30Config.outputFile, step30Config.regressorsOutputFile };
step30 = Step(@PerformDimensionalityAnalysis, ...
              step30Config, ...
              deps30, ...
              outputs30);

%% step 31
% gm pca
step31Config = config.step31;
% gm mask
step31Config.maskVolume = step21Config.outputVolume;
% brain output from detrend
step31Config.brainVolume = step25Config.outputVolume;
step31Config.outputFile = sprintf('%s_%s_pca_gm.mat', ...
                                  subjectName, ...
                                  run);
step31Config.regressorsOutputFile = sprintf('%s_%s_gm_regressors.mat', ...
                                            subjectName, ...
                                            run);
deps31 = { step31Config.maskVolume, step31Config.brainVolume };
outputs31 = { step31Config.outputFile, step31Config.regressorsOutputFile };
step31 = Step(@PerformDimensionalityAnalysis, ...
              step31Config, ...
              deps31, ...
              outputs31);

%% step 32
% global signal pca
step32Config = config.step32;
% brain mask filled
step32Config.maskVolume = step24Config.outputVolume;
% brain output from detrend
step32Config.brainVolume = step25Config.outputVolume;
step32Config.outputFile = sprintf('%s_%s_pca_gs.mat', ...
                                  subjectName, ...
                                  run);
step32Config.regressorsOutputFile = sprintf('%s_%s_gs_regressors.mat', ...
                                            subjectName, ...
                                            run);
deps32 = { step32Config.maskVolume, step32Config.brainVolume };
outputs32 = { step32Config.outputFile, step32Config.regressorsOutputFile };
step32 = Step(@PerformDimensionalityAnalysis, ...
              step32Config, ...
              deps32, ...
              outputs32);

%% step 33
% perform regression
step33Config = config.step33;
% brain mask filled
step33Config.maskVolume = step24Config.outputVolume;
% brain output from detrend
step33Config.brainVolume = step25Config.outputVolume;
step33Config.outputVolume = sprintf('%s_%s_regressed.nii.gz', ...
                                    subjectName, ...
                                    run);
step33Config.outlierFiles = { ...
  step26OutliersOutputFile, ...    % fd motion outlier
  step27OutliersOutputFile, ...    % dvars motion outlier
  step28Config.outputOutliers, ... % standard deviation outliers
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
deps33 = [ step33Config.maskVolume, ...
           step33Config.brainVolume, ...
           step33Config.outlierFiles(:)', ...
           step33Config.regressorFiles(:)' ];
outputs33 = { step33Config.outputVolume, ...
              step33Config.regressorsOutputFile, ...
              step33Config.outliersOutputFile };
step33 = Step(@PerformRegression, ...
              step33Config, ...
              deps33, ...
              outputs33);

%% step 34
% global signal time series
step34Config = config.step34;
% brain output from regression
step34Config.brainVolume = step33Config.outputVolume;
% brain mask filled
step34Config.maskVolume = step24Config.outputVolume;
step34Config.outputFile = sprintf('%s_%s_ts_gs.mat', ...
                                  subjectName, ...
                                  run);
deps34 = { step34Config.maskVolume, step34Config.brainVolume };
outputs34 = { step34Config.outputFile };
step34 = Step(@SaveMaskedTimeSeries, ...
              step34Config, ...
              deps34, ...
              outputs34);

%% step 35
% gray matter time series
step35Config = config.step35;
% brain output from regression
step35Config.brainVolume = step33Config.outputVolume;
% gray matter mask
step35Config.maskVolume = step19Config.outputVolume;
step35Config.outputFile = sprintf('%s_%s_ts_gm.mat', ...
                                  subjectName, ...
                                  run);
deps35 = { step35Config.maskVolume, step35Config.brainVolume };
outputs35 = { step35Config.outputFile };
step35 = Step(@SaveMaskedTimeSeries, ...
              step35Config, ...
              deps35, ...
              outputs35);

%% step 36
% white matter time series
step36Config = config.step36;
% brain output from regression
step36Config.brainVolume = step33Config.outputVolume;
% white matter mask eroded
step36Config.maskVolume = step15Config.outputVolume;
step36Config.outputFile = sprintf('%s_%s_ts_wm.mat', ...
                                  subjectName, ...
                                  run);
deps36 = { step36Config.maskVolume, step36Config.brainVolume };
outputs36 = { step36Config.outputFile };
step36 = Step(@SaveMaskedTimeSeries, ...
              step36Config, ...
              deps36, ...
              outputs36);

%% step 37
% csfvent time series
step37Config = config.step37;
% brain output from regression
step37Config.brainVolume = step33Config.outputVolume;
% csf vent mask eroded
step37Config.maskVolume = step18Config.outputVolume;
step37Config.outputFile = sprintf('%s_%s_ts_csfvent.mat', ...
                                  subjectName, ...
                                  run);
deps37 = { step37Config.maskVolume, step37Config.brainVolume };
outputs37 = { step37Config.outputFile };
step37 = Step(@SaveMaskedTimeSeries, ...
              step37Config, ...
              deps37, ...
              outputs37);

%% step 38
% band pass filter
step38Config = config.step38;
% brain output from regression
step38Config.inputVolume = step33Config.outputVolume;
% gs time series
step38Config.timeSeriesFile = step34Config.outputFile;
step38Config.outputVolume = sprintf('%s_%s_bandpass.nii.gz', ...
                                    subjectName, ...
                                    run);
deps38 = { step38Config.inputVolume, step38Config.timeSeriesFile };
outputs38 = { step38Config.outputVolume };
step38 = Step(@ApplyBandPassFilter, ...
              step38Config, ...
              deps38, ...
              outputs38);

%% step 39
% regress out pca1
step39Config = config.step39;
% brain mask filled
step39Config.maskVolume = step24Config.outputVolume;
% brain output from regression
step39Config.brainVolume = step33Config.outputVolume;
step39Config.outputVolume = sprintf('%s_%s_pca%d.nii.gz', ...
                                    subjectName, ...
                                    run, ...
                                    step39Config.numComponents);
step39Config.pcaFiles = { ...
  step29Config.outputFile, ... % csfvent pca
  step30Config.outputFile, ... % wm pca
  step32Config.outputFile, ... % gs pca
};
deps39 = [ step39Config.maskVolume, ...
           step39Config.brainVolume, ...
           step39Config.pcaFiles(:)' ];
outputs39 = { step39Config.outputVolume };
step39 = Step(@RegressOutPca, ...
              step39Config, ...
              deps39, ...
              outputs39);

%% step 40
% regress out pca3
step40Config = config.step40;
% brain mask filled
step40Config.maskVolume = step24Config.outputVolume;
% brain output from regression
step40Config.brainVolume = step33Config.outputVolume;
step40Config.outputVolume = sprintf('%s_%s_pca%d.nii.gz', ...
                                    subjectName, ...
                                    run, ...
                                    step40Config.numComponents);
step40Config.pcaFiles = { ...
  step29Config.outputFile, ... % csfvent pca
  step30Config.outputFile, ... % wm pca
  step32Config.outputFile, ... % gs pca
};
deps40 = [ step40Config.maskVolume, ...
           step40Config.brainVolume, ...
           step40Config.pcaFiles(:)' ];
outputs40 = { step40Config.outputVolume };
step40 = Step(@RegressOutPca, ...
              step40Config, ...
              deps40, ...
              outputs40);

%% step 41
% regress out pca5
step41Config = config.step41;
% brain mask filled
step41Config.maskVolume = step24Config.outputVolume;
% brain output from regression
step41Config.brainVolume = step33Config.outputVolume;
step41Config.outputVolume = sprintf('%s_%s_pca%d.nii.gz', ...
                                    subjectName, ...
                                    run, ...
                                    step41Config.numComponents);
step41Config.pcaFiles = { ...
  step29Config.outputFile, ... % csfvent pca
  step30Config.outputFile, ... % wm pca
  step32Config.outputFile, ... % gs pca
};
deps41 = [ step41Config.maskVolume, ...
           step41Config.brainVolume, ...
           step41Config.pcaFiles(:)' ];
outputs41 = { step41Config.outputVolume };
step41 = Step(@RegressOutPca, ...
              step41Config, ...
              deps41, ...
              outputs41);

%% step 42
% extract rois pca 1
step42Config = config.step42;
% brain mask filled
step42Config.referenceVolume = step24Config.outputVolume;
% gm parcellation without small clusters
step42Config.parcellationVolume = step22Config.outputVolume;
% brain output from pca 1 regression
step42Config.brainVolume = step39Config.outputVolume;
step42Config.outputFile = sprintf('%s_%s_pca1_rois.mat', ...
                                  subjectName, ...
                                  run);
step42Config.maskVolumes = { ...
  step15Config.outputVolume, ... % wm mask eroded
  step18Config.outputVolume, ... % csfvent mask eroded
};
deps42 = [ step42Config.referenceVolume, ...
           step42Config.brainVolume, ...
           step42Config.maskVolumes(:)' ];
outputs42 = { step42Config.outputFile };
step42 = Step(@ExtractRois, ...
              step42Config, ...
              deps42, ...
              outputs42);

%% step 43
% extract rois pca 3
step43Config = config.step43;
% brain mask filled
step43Config.referenceVolume = step24Config.outputVolume;
% gm parcellation without small clusters
step43Config.parcellationVolume = step22Config.outputVolume;
% brain output from pca 3 regression
step43Config.brainVolume = step40Config.outputVolume;
step43Config.outputFile = sprintf('%s_%s_pca3_rois.mat', ...
                                  subjectName, ...
                                  run);
step43Config.maskVolumes = { ...
  step15Config.outputVolume, ... % wm mask eroded
  step18Config.outputVolume, ... % csfvent mask eroded
};
deps43 = [ step43Config.referenceVolume, ...
           step43Config.brainVolume, ...
           step43Config.maskVolumes(:)' ];
outputs43 = { step43Config.outputFile };
step43 = Step(@ExtractRois, ...
              step43Config, ...
              deps43, ...
              outputs43);

%% step 43
% extract rois pca 5
step44Config = config.step44;
% brain mask filled
step44Config.referenceVolume = step24Config.outputVolume;
% gm parcellation without small clusters
step44Config.parcellationVolume = step22Config.outputVolume;
% brain output from pca 5 regression
step44Config.brainVolume = step41Config.outputVolume;
step44Config.outputFile = sprintf('%s_%s_pca5_rois.mat', ...
                                  subjectName, ...
                                  run);
step44Config.maskVolumes = { ...
  step15Config.outputVolume, ... % wm mask eroded
  step18Config.outputVolume, ... % csfvent mask eroded
};
deps44 = [ step44Config.referenceVolume, ...
           step44Config.brainVolume, ...
           step44Config.maskVolumes(:)' ];
outputs44 = { step44Config.outputFile };
step44 = Step(@ExtractRois, ...
              step44Config, ...
              deps44, ...
              outputs44);

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
          step41, ...
          step42, ...
          step43, ...
          step44 };

% these files will be copied from the workspace to the output path
% todo: add final version
outputs = { step1Config.outputVolume, ...
            step3Config.outputVolume, ...
            step3Config.outputVolume, ...
            step4Config.outputVolume, ...
            step5Config.outputVolume, ...
            step6Config.outputVolume, ...
            step7Config.outputVolume, ...
            step8Config.outputVolume, ...
            step9Config.outputVolume };

sequence = Sequence(steps, ...
                    inputs, ...
                    outputs, ...
                    pathToWorkspace, ...
                    pathToOutput, ...
                    config.sequence);

end

