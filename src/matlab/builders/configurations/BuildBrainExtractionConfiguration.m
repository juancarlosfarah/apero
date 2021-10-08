function [config] = BuildBrainExtractionConfiguration()
%BUILDBRAINEXTRACTIONCONFIGURATION Builds configuration for pipeline.
%   Builds a configuration for a sample brain extraction pipeline.
%
%   Input:
%   - ...
%
%   Output:
%   - config: Configuration.


config = struct;

% get data folder relative to this file
filePath = fileparts(which(mfilename));
pathToDataFolder = fullfile(filePath, '../../../../../neurochi/data/');
pathToWorkspace = fullfile(pathToDataFolder, 'workspace');
pathToDataset = fullfile(pathToDataFolder, 'input');
% for intermediary pipelines, send output to the transfer folder
pathToOutput = fullfile(pathToDataFolder, 'transfer');

%% pipeline: brain extraction
% common configuration
config.verbose = true;
config.clobber = true;
config.pathToWorkspace = pathToWorkspace;
config.pathToDataset = pathToDataset;
config.pathToOutput = pathToOutput;
% helps debug by not running all subjects
config.numSubjects = 2;
config.parallel = true;

% sequence level configurations
config.sequence.startStep = 1;
config.sequence.noCleanUp = true;

%% step 1
% reorient to standard (has to happen before running fsl_anat)
step1.verbose = config.verbose;
step1.clobber = config.clobber;
step1.optional = true;

%% step 2
% crop
step2.verbose = config.verbose;
step2.clobber = config.clobber;
step2.optional = true;

%% step 3
% denoise
step3.verbose = config.verbose;
step3.clobber = config.clobber;
step3.optional = false;

%% step 4
% use fsl_anat to bias correct and get subcortical segmentation
step4.clobber = true;
step4.noReorient = true;
step4.noCrop = true;
step5.verbose = config.verbose;

%% step 5
% use bet for brain extraction
step5.type = 'R';
step5.f = 0.4;
step5.m = true;
step5.optional = false;
step5.clobber = config.clobber;
step5.verbose = config.verbose;

%% step 6
% fill holes
step6.optional = false;
step6.clobber = config.clobber;
step6.verbose = config.verbose;

%% step 7
% multiply brain by mask
step7.optional = false;
step7.clobber = config.clobber;
step7.verbose = config.verbose;

config.step1 = step1; 
config.step2 = step2;
config.step3 = step3;
config.step4 = step4;
config.step5 = step5;
config.step6 = step6;
config.step7 = step7;

end

