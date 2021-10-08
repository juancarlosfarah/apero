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
step1Config = config.step1;
step1Config.inputVolume = sprintf('%s_T1w_brain_trim.nii.gz', subjectName);
step1Config.out = sprintf('%s_T1w_brain', subjectName);
deps1 = { step1Config.inputVolume };
segmentationOutput = sprintf('%s_seg.nii.gz', step1Config.out);
outputs1 = { sprintf('%s_seg.nii.gz', step1Config.out) };
step1 = Step(@CreateSegmentation, ...
             step1Config, ...
             deps1, ...
             outputs1);

%% step 2
% threshold csf mask
step2Config = config.step2;
step2Config.inputVolume = segmentationOutput;
step2Config.outputVolume = sprintf('%s_T1w_csf_mask.nii.gz', subjectName);
deps2 = { step2Config.inputVolume };
outputs2 = { step2Config.outputVolume };
step2 = Step(@ThresholdVolume, ...
             step2Config, ...
             deps2, ...
             outputs2);

%% step 3
% invert csf mask
step3Config = config.step3;
step3Config.inputVolume = step2Config.outputVolume;
step3Config.outputVolume = sprintf('%s_T1w_csf_mask_inv.nii.gz', subjectName);
deps3 = { step3Config.inputVolume };
outputs3 = { step3Config.outputVolume };
step3 = Step(@InvertBinaryMask, ...
             step3Config, ...
             deps3, ...
             outputs3);

%% step 4
% binarize subcortical segmentation
step4Config = config.step4;
step4Config.inputVolume = 'T1_subcort_seg.nii.gz';
step4Config.outputVolume = 'T1_subcort_mask.nii.gz';
deps4 = { step4Config.inputVolume };
outputs4 = { step4Config.outputVolume };
step4 = Step(@Binarize, ...
             step4Config, ...
             deps4, ...
             outputs4);

%% step 5
% mask the subcortical mask with the inverted csf mask
step5Config = config.step5;
% subcortical mask
step5Config.inputVolume = step4Config.outputVolume;
% inverted csf mask
step5Config.maskVolume = step3Config.outputVolume;
step5Config.outputVolume = 'T1_subcort_mask_wo_csf.nii.gz';
deps5 = { step5Config.inputVolume, step5Config.maskVolume };
outputs5 = { step5Config.outputVolume };
step5 = Step(@ApplyMask, ...
             step5Config, ...
             deps5, ...
             outputs5);


%% step 6
% invert subcortical mask w/o csf
step6Config = config.step6;
% subcortical w/o csf mask
step6Config.inputVolume = step5Config.outputVolume;
step6Config.outputVolume = 'T1_subcort_mask_wo_csf_inv.nii.gz';
deps6 = { step6Config.inputVolume };
outputs6 = { step6Config.outputVolume };
step6 = Step(@InvertBinaryMask, ...
             step6Config, ...
             deps6, ...
             outputs6);

%% step 7
% multiply segmented brain by inverted subcortical mask
% i.e. set subcortical positions to 0
step7Config = config.step7;
% segmented brain
step7Config.inputVolume1 = segmentationOutput;
% inverted subcortical mask
step7Config.inputVolume2 = step6Config.outputVolume;
step7Config.outputVolume = sprintf('%s_T1w_brain_wo_subcort.nii.gz', subjectName);
deps7 = { step7Config.inputVolume1, step7Config.inputVolume2 };
outputs7 = { step7Config.outputVolume };
step7 = Step(@MultiplyVolumes, ...
             step7Config, ...
             deps7, ...
             outputs7);

%% step 8
% multiply subcortical mask by 2 to tag as gray matter
step8Config = config.step8;
% subcortical w/o csf mask
step8Config.inputVolume = step5Config.outputVolume;
step8Config.factor = 2;
step8Config.outputVolume = 'T1_subcort_mask_gm.nii.gz';
deps8 = { step8Config.inputVolume };
outputs8 = { step8Config.outputVolume };
step8 = Step(@Multiply, ...
             step8Config, ...
             deps8, ...
             outputs8);

%% step 9
% add gray matter subcortical mask to segmented brain w/o subcortical
step9Config = config.step9;
% segmented brain w/o subcortical
step9Config.inputVolume1 = step7Config.outputVolume;
% subcortical mask tagged as gray matter
step9Config.inputVolume2 = step8Config.outputVolume;
step9Config.outputVolume = sprintf('%s_T1w_brain_subcort.nii.gz', subjectName);
deps9 = { step9Config.inputVolume1, step9Config.inputVolume2 };
outputs9 = { step9Config.outputVolume };
step9 = Step(@AddVolumes, ...
             step9Config, ...
             deps9, ...
             outputs9);

%% step 10
% create masks by tissue type
step10Config = config.step10;
% segmented brain with subcortical
step10Config.inputVolume = step9Config.outputVolume;
deps10 = { step10Config.inputVolume };
% this step outputs names according to the CreateTissueTypeMasks op
outputs10 = { 'T1w_csf_mask.nii.gz', ...
              'T1w_wm_mask.nii.gz', ...
              'T1w_gm_mask.nii.gz' };
step10 = Step(@CreateTissueTypeMasks, ...
              step10Config, ...
              deps10, ...
              outputs10);

%% step 11
% dilate wm mask
step11Config = config.step11;
step11Config.inputVolume = 'T1w_wm_mask.nii.gz';
step11Config.outputVolume = 'T1w_wm_mask_dil.nii.gz';
deps11 = { step11Config.inputVolume };
outputs11 = { step11Config.outputVolume };
step11 = Step(@Dilate, ...
              step11Config, ...
              deps11, ...
              outputs11);


%% step 12
% dilate csf mask
step12Config = config.step12;
% segmented brain with subcortical
step12Config.inputVolume = 'T1w_csf_mask.nii.gz';
step12Config.outputVolume = 'T1w_csf_mask_dil.nii.gz';
deps12 = { step12Config.inputVolume };
outputs12 = { step12Config.outputVolume };
step12 = Step(@Dilate, ...
              step12Config, ...
              deps12, ...
              outputs12);

%% step 13
% combine wm and csf dilated masks
step13Config = config.step13;
step13Config.inputVolume1 = step11Config.outputVolume;  % dilated wm mask
step13Config.inputVolume2 = step12Config.outputVolume;  % dilated csf mask
step13Config.outputVolume = 'T1w_csf_wm_mask.nii.gz';
deps13 = { step13Config.inputVolume1, step13Config.inputVolume2 };
outputs13 = { step13Config.outputVolume };
step13 = Step(@AddVolumes, ...
             step13Config, ...
             deps13, ...
             outputs13);

%% step 14
% threshold combined wm and csf mask to keep only the overlap
step14Config = config.step14;
% combined wm and csf mask
step14Config.inputVolume = step13Config.outputVolume;
step14Config.outputVolume = 'T1w_csf_wm_mask_overlap.nii.gz';
deps14 = { step14Config.inputVolume };
outputs14 = { step14Config.outputVolume };
step14 = Step(@ThresholdVolume, ...
              step14Config, ...
              deps14, ...
              outputs14);

%% step 15
% multiply ventrical csf with wm csf boundary to trim edges
step15Config = config.step15;
% overlap of wm and csf mask
step15Config.inputVolume1 = step14Config.outputVolume;
step15Config.inputVolume2 = sprintf('mask_ventricles_MNIch2_%s.nii.gz', ...
                                    subjectName);
step15Config.outputVolume = 'T1w_csf_wm_mask_overlap_trim.nii.gz';
deps15 = { step15Config.inputVolume1, step15Config.inputVolume2 };
outputs15 = { step15Config.outputVolume };
step15 = Step(@MultiplyVolumes, ...
              step15Config, ...
              deps15, ...
              outputs15);

%% step 16
% binarize and invert csf and wm overlap mask
step16Config = config.step16;
% clean overlap of wm and csf mask
step16Config.inputVolume = step15Config.outputVolume;
step16Config.outputVolume = 'T1w_csf_wm_mask_overlap_binv.nii.gz';
deps16 = { step16Config.inputVolume };
outputs16 = { step16Config.outputVolume };
step16 = Step(@BinarizeInvert, ...
              step16Config, ...
              deps16, ...
              outputs16);

%% step 17
% multiply csf and wm overlap with gm mask to trim edges
step17Config = config.step17;
% binarized overlap of wm and csf mask
step17Config.inputVolume1 = step16Config.outputVolume;
step17Config.inputVolume2 = 'T1w_gm_mask.nii.gz';
step17Config.outputVolume = 'T1w_gm_mask_trim.nii.gz';
deps17 = { step17Config.inputVolume1, step17Config.inputVolume2 };
outputs17 = { step17Config.outputVolume };
step17 = Step(@MultiplyVolumes, ...
              step17Config, ...
              deps17, ...
              outputs17);

%% step 18
% erode the wm mask's outer parts to be sure that it is wm
step18Config = config.step18;
step18Config.inputVolume = 'T1w_wm_mask.nii.gz';
step18Config.outputVolume = 'T1w_wm_mask_ero.nii.gz';
deps18 = { step18Config.inputVolume };
outputs18 = { step18Config.outputVolume };
step18 = Step(@Erode, ...
              step18Config, ...
              deps18, ...
              outputs18);

%% step 19
% erode the csf mask's outer parts to be sure that it is csf
step19Config = config.step19;
step19Config.inputVolume = 'T1w_csf_mask.nii.gz';
step19Config.outputVolume = 'T1w_csf_mask_ero.nii.gz';
deps19 = { step19Config.inputVolume };
outputs19 = { step19Config.outputVolume };
step19 = Step(@Erode, ...
              step19Config, ...
              deps19, ...
              outputs19);

%% step 20
% apply ventricles mask to eroded csf mask
step20Config = config.step20;
% eroded csf mask
step20Config.inputVolume = step19Config.outputVolume;
step20Config.maskVolume = sprintf('mask_ventricles_MNIch2_%s.nii.gz', ...
                                  subjectName);
step20Config.outputVolume = 'T1w_csfvent_mask_ero.nii.gz';
deps20 = { step20Config.inputVolume, step20Config.maskVolume };
outputs20 = { step20Config.outputVolume };
step20 = Step(@ApplyMask, ...
              step20Config, ...
              deps20, ...
              outputs20);

%% step 21
% erode inverted subcortical mask
step21Config = config.step21;
% inverted subcortical mask without csf
step21Config.inputVolume = step6Config.outputVolume;
step21Config.outputVolume = 'T1_subcort_mask_wo_csf_inv_ero.nii.gz';
deps21 = { step21Config.inputVolume };
outputs21 = { step21Config.outputVolume };
step21 = Step(@Erode, ...
              step21Config, ...
              deps21, ...
              outputs21);

%% step 22
% intersect parcellation with gm mask
step22Config = config.step22;
% parcellation
step22Config.inputVolume1 = sprintf('%s_%s.nii.gz', ...
                                    parcellation, ...
                                    subjectName);
% trimmed gm mask
step22Config.inputVolume2 = step17Config.outputVolume;
step22Config.outputVolume = sprintf('%s_T1w_gm_parc.nii.gz', subjectName);
deps22 = { step22Config.inputVolume1, step22Config.inputVolume2 };
outputs22 = { step22Config.outputVolume };
step22 = Step(@MultiplyVolumes, ...
              step22Config, ...
              deps22, ...
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
outputs = [ outputs10(:)', ...
            step18Config.outputVolume, ...
            step19Config.outputVolume, ...
            step20Config.outputVolume, ...
            step22Config.outputVolume ];

sequence = Sequence(steps, ...
                    inputs, ...
                    outputs, ...
                    pathToWorkspace, ...
                    pathToOutput, ...
                    config.sequence);

end

