% maybe renameBrainExtractionSequenceTemplate() this BrainExtractionTemplate()

function [sequence] = BuildBrainExtractionSequence()

sequence = Sequence();

%% inputs required to start the sequence
inputs = { 'anat/{subject}_T1w.nii.gz', '{yeo15}' };
sequence.Inputs = inputs;

% inputs = { 'anat/{subject}_T1w.nii.gz', 'func/{subject}_task-convers_{run}_bold.nii.gz', '{yeo15}' };

%% step defaults
% set defaults that will apply for each step
default = struct();
default.configuration.verbose = true;
default.configuration.clobber = false;
default.configuration.optional = false;

%% all this goes to the "cohort"
% get data folder relative to this file
% filePath = fileparts(which(mfilename));
% pathToDataFolder = fullfile(filePath, '../../../../../neurochi/data/');
% pathToWorkspace = fullfile(pathToDataFolder, 'workspace');
% pathToDataset = fullfile(pathToDataFolder, 'input');
% % for intermediary pipelines, send output to the transfer folder
% pathToOutput = fullfile(pathToDataFolder, 'transfer');
% % common configuration
% definition.pathToWorkspace = pathToWorkspace;
% definition.pathToDataset = pathToDataset;
% definition.pathToOutput = pathToOutput;
% % helps debug by not running all subjects
% definition.numSubjects = 2;
% definition.parallel = true;

%% this should be changed at the pipeline level
% sequence level configurations
% definition.sequence.startStep = 1;
% definition.sequence.noCleanUp = true;

%% step 1
% reorient to standard (has to happen before running fsl_anat)
step1 = default;
step1.operation = @ReorientToStandard;
step1.configuration.inputVolume = '{subject}_T1w.nii.gz';
step1.configuration.outputVolume = '{subject}_T1w_std.nii.gz';
step1.dependencies = { step1.configuration.inputVolume };
step1.outputs = { step1.configuration.outputVolume };
% add step to sequence
sequence.addStep(step1);

%% step 2
% crop
step2 = default;
step2.operation = @Crop;
step2.configuration.inputVolume = step1.configuration.outputVolume;
step2.configuration.outputVolume = '{subject}_T1w_crop.nii.gz';
step2.dependencies = { step2.configuration.inputVolume };
step2.outputs = { step2.configuration.outputVolume };
% add step to sequence
sequence.addStep(step2);

%% step 3
% denoise
step3 = default;
step3.operation = @DenoiseImage;
step3.configuration.inputFile = step2.configuration.outputVolume;
step3.configuration.outputFile = '{subject}_T1w_denoised.nii';
step3.dependencies = { step3.configuration.inputFile };
step3.outputs = { step3.configuration.outputFile };
% add step to sequence
sequence.addStep(step3);

%% step 4
% use fsl_anat to bias correct and get subcortical segmentation
step4 = default;
step4.operation = @ProcessAnatomicalImage;
step4.configuration.noReorient = true;
step4.configuration.noCrop = true;
step4.configuration.inputFile = step3.configuration.outputFile;
step4.configuration.outputFolder = '{subject}';
step4.dependencies = { step4.configuration.inputFile };
step4.outputs = { ...
  '{subject}.anat/T1_biascorr.nii.gz', ...
  '{subject}.anat/T1_subcort_seg.nii.gz', ...
};
% add step to sequence
sequence.addStep(step4);

%% step 5
% extract brain
step5 = default;
step5.operation = @ExtractBrain;
step5.configuration.type = 'R';
step5.configuration.f = 0.4;
step5.configuration.m = true;
step5.configuration.inputVolume = '{subject}.anat/T1_biascorr.nii.gz';
step5.configuration.outputVolume = '{subject}_T1w_brain.nii.gz';
step5.dependencies = { step5.configuration.inputVolume };
step5.outputs = { step5.configuration.outputVolume };
% add step to sequences
sequence.addStep(step5);

%% step 6
% fill holes
step6 = default;
step6.operation = @FillHoles;
step6.configuration.inputVolume = '{subject}_T1w_brain_mask.nii.gz';
step6.configuration.outputVolume = '{subject}_T1w_brain_mask_filled.nii.gz';
step6.dependencies = { step6.configuration.inputVolume };
step6.outputs = { step6.configuration.outputVolume };
% add step to sequence
sequence.addStep(step6);

%% step 7
% multiply brain by mask
% extra step to be very precise on the extraction
step7 = default;
step7.operation = @MultiplyVolumes;
step7.configuration.inputVolume1 = '{subject}.anat/T1_biascorr.nii.gz';
step7.configuration.inputVolume2 = '{subject}_T1w_brain_mask_filled.nii.gz';
step7.configuration.outputVolume = '{subject}_T1w_brain_trim.nii.gz';
step7.dependencies = { step7.configuration.inputVolume1, ...
                       step7.configuration.inputVolume2 };
step7.outputs = { step7.configuration.outputVolume };
% add step to sequence
sequence.addStep(step7);

%% outputs from the sequence
% these files will be copied from the workspace to the output path
outputs = { '{subject}_T1w.nii.gz',  ...
            '{subject}_T1w_brain.nii.gz', ...
            '{subject}_T1w_brain_mask_filled.nii.gz', ...
            '{subject}.anat/T1_subcort_seg.nii.gz', ...
            '{subject}.anat/T1_biascorr.nii.gz', ...
            '{subject}_T1w_brain_trim.nii.gz' };
sequence.Outputs = outputs;

end
