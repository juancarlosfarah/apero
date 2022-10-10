function [definition] = BuildBrainExtractionDefinition()
%BUILDBRAINEXTRACTIONCONFIGURATION Builds configuration for pipeline.
%   Builds a configuration for a sample brain extraction pipeline.
%
%   Input:
%   - ...
%
%   Output:
%   - config: Configuration.


definition = struct;

% get data folder relative to this file
filePath = fileparts(which(mfilename));
pathToDataFolder = fullfile(filePath, '../../../../../neurochi/data/');
pathToWorkspace = fullfile(pathToDataFolder, 'workspace');
pathToDataset = fullfile(pathToDataFolder, 'input');
% for intermediary pipelines, send output to the transfer folder
pathToOutput = fullfile(pathToDataFolder, 'transfer');

%% pipeline: brain extraction
% common configuration
definition.verbose = true;
definition.clobber = true;
definition.pathToWorkspace = pathToWorkspace;
definition.pathToDataset = pathToDataset;
definition.pathToOutput = pathToOutput;
% helps debug by not running all subjects
definition.numSubjects = 2;
definition.parallel = true;

% sequence level configurations
definition.sequence.startStep = 1;
definition.sequence.noCleanUp = true;

%% step 1
% reorient to standard (has to happen before running fsl_anat)
step1.operation = @ReorientToStandard;
step1.configuration.verbose = definition.verbose;
step1.configuration.clobber = definition.clobber;
step1.configuration.optional = true;
step1.configuration.inputVolume = '{subject}_T1w.nii.gz';
step1.configuration.outputVolume = '{subject}_T1w_std.nii.gz';
step1.dependencies = { step1.configuration.inputVolume };
step1.outputs = { step1.configuration.outputVolume };

%% step 2
% crop
step2.operation = @Crop;
step2.configuration.verbose = definition.verbose;
step2.configuration.clobber = definition.clobber;
step2.configuration.optional = true;
step2.configuration.inputVolume = step1Config.outputVolume;
step2.configuration.outputVolume = '{subject}_T1w_crop.nii.gz';
step2.dependencies = { step2.configuration.inputVolume };
step2.outputs = { step2.configuration.outputVolume };

%% step 3
% denoise
step3.operation = @DenoiseImage;
step3.configuration.verbose = definition.verbose;
step3.configuration.clobber = definition.clobber;
step3.configuration.optional = false;
step3.configuration.inputFile = step2.configuration.outputVolume;
step3.configuration.outputFile = '{subject}_T1w_denoised.nii';
step3.dependencies = { step3.configuration.inputFile };
step3.outputs = { step3.configuration.outputFile };

%% step 4
% use fsl_anat to bias correct and get subcortical segmentation
step4.clobber = true;
step4.noReorient = true;
step4.noCrop = true;
step5.verbose = definition.verbose;
%% step 4
% process anatomical image
step4Config = sequenceDefinition.step4;
step4Config.inputFile = step3Config.outputFile;
step4Config.outputFolder = sprintf('%s', subjectName);
deps4 = { step4Config.inputFile };
outputs4 = { ...
  sprintf('%s.anat/T1_biascorr.nii.gz', subjectName), ...
  sprintf('%s.anat/T1_subcort_seg.nii.gz', subjectName), ...
};
step4 = Step(@ProcessAnatomicalImage, ...
             step4Config, ...
             deps4, ...
             outputs4);

%% step 5
% use bet for brain extraction
step5.type = 'R';
step5.f = 0.4;
step5.m = true;
step5.optional = false;
step5.clobber = definition.clobber;
step5.verbose = definition.verbose;
%% step 5
% extract brain
step5Config = sequenceDefinition.step5;
step5Config.inputVolume = sprintf('%s.anat/T1_biascorr.nii.gz', subjectName);
step5Config.outputVolume = sprintf('%s_T1w_brain.nii.gz', subjectName);
deps5 = { step5Config.inputVolume };
outputs5 = { step5Config.outputVolume };
step5 = Step(@ExtractBrain, ...
             step5Config, ...
             deps5, ...
             outputs5);

%% step 6
% fill holes
step6.optional = false;
step6.clobber = definition.clobber;
step6.verbose = definition.verbose;
%% step 6
% fill holes
step6Config = sequenceDefinition.step6;
step6Config.inputVolume = sprintf('%s_T1w_brain_mask.nii.gz', subjectName);
step6Config.outputVolume = sprintf('%s_T1w_brain_mask_filled.nii.gz', subjectName);
deps6 = { step6Config.inputVolume };
outputs6 = { step6Config.outputVolume };
step6 = Step(@FillHoles, ...
             step6Config, ...
             deps6, ...
             outputs6);

%% step 7
% multiply brain by mask
step7.optional = false;
step7.clobber = definition.clobber;
step7.verbose = definition.verbose;
%% step 7
% multiply brain by mask
% extra step to be very precise on the extraction
step7Config = sequenceDefinition.step7;
step7Config.inputVolume1 = sprintf('%s.anat/T1_biascorr.nii.gz', subjectName);
step7Config.inputVolume2 = sprintf('%s_T1w_brain_mask_filled.nii.gz', subjectName);
step7Config.outputVolume = sprintf('%s_T1w_brain_trim.nii.gz', subjectName);
deps7 = { step7Config.inputVolume1, step7Config.inputVolume2 };
outputs7 = { step7Config.outputVolume };
step7 = Step(@MultiplyVolumes, ...
             step7Config, ...
             deps7, ...
             outputs7);

definition.step1 = step1; 
definition.step2 = step2;
definition.step3 = step3;
definition.step4 = step4;
definition.step5 = step5;
definition.step6 = step6;
definition.step7 = step7;


end

