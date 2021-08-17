function [sequence] = BuildSegmentationSequence(parcellation, ...
                                                inputs, ...
                                                subjectName, ...
                                                pathToWorkspace, ...
                                                pathToOutput, ...
                                                config)
%BUILDSEGMENTATIONSEQUENCE Example of a sequence builder.
%   This builder creates the typical sequence to perform the segmentation
%   of a T1w image.
%
%   Input:
%   - inputs:           Inputs that will be copied into the workspace.
%   - pathToWorkspace:  Path to the sequence's workspace.
%   - pathToOutput:     Path to where we will output the data.
%
%   Output:
%   - sequence:  Built sequence.

%% step 1
% create a segmentation
step1Params = struct();
step1Config = config.step1;
step1Params.inputVolume = sprintf('%s_T1w_brain_mul.nii.gz', subjectName);
step1Config.out = sprintf('%s_T1w_brain', subjectName);
deps1 = { step1Params.inputVolume };
segmentationOutput = sprintf('%s_seg.nii.gz', step1Config.out);
outputs1 = { sprintf('%s_seg.nii.gz', step1Config.out) };
step1 = Step(@CreateSegmentation, ...
             step1Params, ...
             deps1, ...
             step1Config, ...
             outputs1);

%% step 2
% threshold csf mask
step2Params = struct();
step2Config = config.step2;
step2Params.inputVolume = segmentationOutput;
step2Params.outputVolume = sprintf('%s_T1w_csf_mask.nii.gz', subjectName);
deps2 = { step2Params.inputVolume };
outputs2 = { step2Params.outputVolume };
step2 = Step(@ThresholdVolume, ...
             step2Params, ...
             deps2, ...
             step2Config, ...
             outputs2);

%% step 3
% invert csf mask
step3Params = struct();
step3Config = config.step3;
step3Params.inputVolume = step2Params.outputVolume;
step3Params.outputVolume = sprintf('%s_T1w_csf_mask_inv.nii.gz', subjectName);
deps3 = { step3Params.inputVolume };
outputs3 = { step3Params.outputVolume };
step3 = Step(@InvertBinaryMask, ...
             step3Params, ...
             deps3, ...
             step3Config, ...
             outputs3);

%% step 4
% binarize subcortical segmentation
step4Params = struct();
step4Config = config.step4;
step4Params.inputVolume = 'T1_subcort_seg.nii.gz';
step4Params.outputVolume = 'T1_subcort_mask.nii.gz';
deps4 = { step4Params.inputVolume };
outputs4 = { step4Params.outputVolume };
step4 = Step(@Binarize, ...
             step4Params, ...
             deps4, ...
             step4Config, ...
             outputs4);

%% step 5
% mask the subcortical mask with the inverted csf mask
step5Params = struct();
step5Config = config.step5;
% subcortical mask
step5Params.inputVolume = step4Params.outputVolume;
% inverted csf mask
step5Params.maskVolume = step3Params.outputVolume;
step5Params.outputVolume = 'T1_subcort_mask_wo_csf.nii.gz';
deps5 = { step5Params.inputVolume, step5Params.maskVolume };
outputs5 = { step5Params.outputVolume };
step5 = Step(@ApplyMask, ...
             step5Params, ...
             deps5, ...
             step5Config, ...
             outputs5);


%% step 6
% invert subcortical mask w/o csf
step6Params = struct();
step6Config = config.step6;
% subcortical w/o csf mask
step6Params.inputVolume = step5Params.outputVolume;
step6Params.outputVolume = 'T1_subcort_mask_wo_csf_inv.nii.gz';
deps6 = { step6Params.inputVolume };
outputs6 = { step6Params.outputVolume };
step6 = Step(@InvertBinaryMask, ...
             step6Params, ...
             deps6, ...
             step6Config, ...
             outputs6);

%% step 7
% multiply segmented brain by inverted subcortical mask
% i.e. set subcortical positions to 0
step7Params = struct();
step7Config = config.step7;
% segmented brain
step7Params.inputVolume1 = segmentationOutput;
% inverted subcortical mask
step7Params.inputVolume2 = step6Params.outputVolume;
step7Params.outputVolume = sprintf('%s_T1w_brain_wo_subcort.nii.gz', subjectName);
deps7 = { step7Params.inputVolume1, step7Params.inputVolume2 };
outputs7 = { step7Params.outputVolume };
step7 = Step(@MultiplyVolumes, ...
             step7Params, ...
             deps7, ...
             step7Config, ...
             outputs7);

%% step 8
% multiply subcortical mask by 2 to tag as gray matter
step8Params = struct();
step8Config = config.step8;
% subcortical w/o csf mask
step8Params.inputVolume = step5Params.outputVolume;
step8Params.factor = 2;
step8Params.outputVolume = 'T1_subcort_mask_gm.nii.gz';
deps8 = { step8Params.inputVolume };
outputs8 = { step8Params.outputVolume };
step8 = Step(@Multiply, ...
             step8Params, ...
             deps8, ...
             step8Config, ...
             outputs8);

%% step 9
% add gray matter subcortical mask to segmented brain w/o subcortical
step9Params = struct();
step9Config = config.step9;
% segmented brain w/o subcortical
step9Params.inputVolume1 = step7Params.outputVolume;
% subcortical mask tagged as gray matter
step9Params.inputVolume2 = step8Params.outputVolume;
step9Params.outputVolume = sprintf('%s_T1w_brain_subcort.nii.gz', subjectName);
deps9 = { step9Params.inputVolume1, step9Params.inputVolume2 };
outputs9 = { step9Params.outputVolume };
step9 = Step(@AddVolumes, ...
             step9Params, ...
             deps9, ...
             step9Config, ...
             outputs9);

%% step 10
% create masks by tissue type
step10Params = struct();
step10Config = config.step10;
% segmented brain with subcortical
step10Params.inputVolume = step9Params.outputVolume;
deps10 = { step10Params.inputVolume };
% this step outputs names according to the CreateTissueTypeMasks op
outputs10 = { 'T1w_csf_mask.nii.gz', ...
              'T1w_vm_mask.nii.gz', ...
              'T1w_gm_mask.nii.gz' };
step10 = Step(@CreateTissueTypeMasks, ...
              step10Params, ...
              deps10, ...
              step10Config, ...
              outputs10);

%% step 11
% dilate wm mask
step11Params = struct();
step11Config = config.step11;
step11Params.inputVolume = 'T1w_wm_mask.nii.gz';
step11Params.outputVolume = 'T1w_wm_mask_dil.nii.gz';
deps11 = { step11Params.inputVolume };
outputs11 = { step11Params.outputVolume };
step11 = Step(@Dilate, ...
              step11Params, ...
              deps11, ...
              step11Config, ...
              outputs11);


%% step 12
% dilate csf mask
step12Params = struct();
step12Config = config.step12;
% segmented brain with subcortical
step12Params.inputVolume = 'T1w_csf_mask.nii.gz';
step12Params.outputVolume = 'T1w_csf_mask_dil.nii.gz';
deps12 = { step12Params.inputVolume };
outputs12 = { step12Params.outputVolume };
step12 = Step(@Dilate, ...
              step12Params, ...
              deps12, ...
              step12Config, ...
              outputs12);

%% step 13
% combine wm and csf dilated masks
step13Params = struct();
step13Config = config.step13;
step13Params.inputVolume1 = step11Params.outputVolume;  % dilated wm mask
step13Params.inputVolume2 = step12Params.outputVolume;  % dilated csf mask
step13Params.outputVolume = 'T1w_csf_wm_mask.nii.gz';
deps13 = { step13Params.inputVolume1, step13Params.inputVolume2 };
outputs13 = { step13Params.outputVolume };
step13 = Step(@AddVolumes, ...
             step13Params, ...
             deps13, ...
             step13Config, ...
             outputs13);

%% step 14
% threshold combined wm and csf mask to keep only the overlap
step14Params = struct();
step14Config = config.step14;
% combined wm and csf mask
step14Params.inputVolume = step13Params.outputVolume;
step14Params.outputVolume = 'T1w_csf_wm_mask_overlap.nii.gz';
deps14 = { step14Params.inputVolume };
outputs14 = { step14Params.outputVolume };
step14 = Step(@ThresholdVolume, ...
              step14Params, ...
              deps14, ...
              step14Config, ...
              outputs14);

%% step 15
% multiply ventrical csf with wm csf boundary to trim edges
step15Params = struct();
step15Config = config.step15;
% overlap of wm and csf mask
step15Params.inputVolume1 = step14Params.outputVolume;
step15Params.inputVolume2 = sprintf('mask_ventricles_MNIch2_%s.nii.gz', ...
                                    subjectName);
step15Params.outputVolume = 'T1w_csf_wm_mask_overlap_trim.nii.gz';
deps15 = { step15Params.inputVolume1, step15Params.inputVolume2 };
outputs15 = { step15Params.outputVolume };
step15 = Step(@MultiplyVolumes, ...
              step15Params, ...
              deps15, ...
              step15Config, ...
              outputs15);

%% step 16
% binarize and invert csf and wm overlap mask
step16Params = struct();
step16Config = config.step16;
% clean overlap of wm and csf mask
step16Params.inputVolume = step15Params.outputVolume;
step16Params.outputVolume = 'T1w_csf_wm_mask_overlap_binv.nii.gz';
deps16 = { step16Params.inputVolume };
outputs16 = { step16Params.outputVolume };
step16 = Step(@BinarizeInvert, ...
              step16Params, ...
              deps16, ...
              step16Config, ...
              outputs16);

%% step 17
% multiply csf and wm overlap with gm mask to trim edges
step17Params = struct();
step17Config = config.step17;
% binarized overlap of wm and csf mask
step17Params.inputVolume1 = step16Params.outputVolume;
step17Params.inputVolume2 = 'T1w_gm_mask.nii.gz';
step17Params.outputVolume = 'T1w_gm_mask_trim.nii.gz';
deps17 = { step17Params.inputVolume1, step17Params.inputVolume2 };
outputs17 = { step17Params.outputVolume };
step17 = Step(@MultiplyVolumes, ...
              step17Params, ...
              deps17, ...
              step17Config, ...
              outputs17);

%% step 18
% erode the wm mask's outer parts to be sure that it is wm
step18Params = struct();
step18Config = config.step18;
step18Params.inputVolume = 'T1w_wm_mask.nii.gz';
step18Params.outputVolume = 'T1w_wm_mask_ero.nii.gz';
deps18 = { step18Params.inputVolume };
outputs18 = { step18Params.outputVolume };
step18 = Step(@Erode, ...
              step18Params, ...
              deps18, ...
              step18Config, ...
              outputs18);

%% step 19
% erode the csf mask's outer parts to be sure that it is csf
step19Params = struct();
step19Config = config.step19;
step19Params.inputVolume = 'T1w_csf_mask.nii.gz';
step19Params.outputVolume = 'T1w_csf_mask_ero.nii.gz';
deps19 = { step19Params.inputVolume };
outputs19 = { step19Params.outputVolume };
step19 = Step(@Erode, ...
              step19Params, ...
              deps19, ...
              step19Config, ...
              outputs19);

%% step 20
% apply ventricles mask to eroded csf mask
step20Params = struct();
step20Config = config.step20;
% eroded csf mask
step20Params.inputVolume = step19Params.outputVolume;
step20Params.maskVolume = sprintf('mask_ventricles_MNIch2_%s.nii.gz', ...
                                  subjectName);
step20Params.outputVolume = 'T1w_csfvent_mask_ero.nii.gz';
deps20 = { step20Params.inputVolume, step20Params.maskVolume };
outputs20 = { step20Params.outputVolume };
step20 = Step(@ApplyMask, ...
              step20Params, ...
              deps20, ...
              step20Config, ...
              outputs20);

%% step 21
% erode inverted subcortical mask
step21Params = struct();
step21Config = config.step21;
% inverted subcortical mask without csf
step21Params.inputVolume = step6Params.outputVolume;
step21Params.outputVolume = 'T1_subcort_mask_wo_csf_inv_ero.nii.gz';
deps21 = { step21Params.inputVolume };
outputs21 = { step21Params.outputVolume };
step21 = Step(@Erode, ...
              step21Params, ...
              deps21, ...
              step21Config, ...
              outputs21);

%% step 22
% intersect parcellation with gm mask
step22Params = struct();
step22Config = config.step22;
% parcellation
step22Params.inputVolume1 = sprintf('%s_%s.nii.gz', ...
                                    parcellation, ...
                                    subjectName);
% trimmed gm mask
step22Params.inputVolume2 = step17Params.outputVolume;
step22Params.outputVolume = sprintf('%s_T1w_gm_parc.nii.gz', subjectName);
deps22 = { step22Params.inputVolume1, step22Params.inputVolume2 };
outputs22 = { step22Params.outputVolume };
step22 = Step(@MultiplyVolumes, ...
              step22Params, ...
              deps22, ...
              step22Config, ...
              outputs22);

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
          step22 };

% these files will be copied from the workspace to the output path
outputs = { segmentationOutput, ...
            step2Params.outputVolume, ...
            step3Params.outputVolume, ...
            step4Params.outputVolume, ...
            step5Params.outputVolume };

sequence = Sequence(steps, ...
                    inputs, ...
                    outputs, ...
                    pathToWorkspace, ...
                    pathToOutput, ...
                    config.sequence);

end

