function [config] = BuildSegmentationConfiguration(parcellation)
%BUILDSEGMENTATIONCONFIGURATION Builds configuration for a pipeline.
%   Builds a configuration for a pipeline that performs segmentation.
%
%   Input:
%   - ...
%
%   Output:
%   - config: Configuration.

config = struct();

% get data folder relative to this file
filePath = fileparts(which(mfilename));
pathToDataFolder = fullfile(filePath, '../../../../../neurochi/data/');
pathToWorkspace = fullfile(pathToDataFolder, 'workspace');
pathToDataset = fullfile(pathToDataFolder, 'input');
pathToParcellations = fullfile(pathToDataFolder, 'parcs');
% for intermediary pipelines, send output to the transfer folder
pathToOutput = fullfile(pathToDataFolder, 'transfer');

%% pipeline: segmentation
% common configuration
config.verbose = false;
config.clobber = false;
config.pathToWorkspace = pathToWorkspace;
config.pathToDataset = pathToDataset;
config.pathToParcellations = pathToParcellations;
config.pathToOutput = pathToOutput;
% helps debug by not running all subjects
% (0 runs all subjects)
config.numSubjects = 0;
config.parcellation = parcellation;
config.parallel = true;

% sequence level configurations
config.sequence.startStep = 1;
config.sequence.noCleanUp = true;


% step 1: fast
config.step1.H = 0.25;
config.step1.optional = false;
config.step1.skip = false;
config.step1.clobber = config.clobber;
config.step1.verbose = config.verbose;

% step 2: threshold
config.step2.thr = 1;
config.step2.uthr = 1;
config.step2.optional = false;
config.step2.skip = false;
config.step2.clobber = config.clobber;
config.step2.verbose = config.verbose;

% step 3: invert
config.step3.optional = false;
config.step3.skip = false;
config.step3.clobber = config.clobber;
config.step3.verbose = config.verbose;

% step 4: binarize
config.step4.skip = false;
config.step4.optional = false;
config.step4.clobber = config.clobber;
config.step4.verbose = config.verbose;

% step 5: apply mask
config.step5.optional = false;
config.step5.skip = false;
config.step5.clobber = config.clobber;
config.step5.verbose = config.verbose;

% step 6: invert subcortical mask
config.step6.optional = false;
config.step6.skip = false;
config.step6.clobber = config.clobber;
config.step6.verbose = config.verbose;

% step 7: multiply segmented brain by inverted subcortical mask
config.step7.skip = false;
config.step7.clobber = config.clobber;
config.step7.verbose = config.verbose;

% step 8: tag subcortical mask as gray matter
config.step8.skip = false;
config.step8.verbose = config.verbose;
config.step8.clobber = config.clobber;

% step 9: add subcortical mask back to segmented brain
config.step9.skip = false;
config.step9.clobber = config.clobber;

% step 10: create tissue type masks
config.step10.skip = false;
config.step10.clobber = config.clobber;

% step 11: dilate wm mask
config.step11.skip = false;
config.step11.clobber = config.clobber;

% step 12: dilate csf mask
config.step12.skip = false;
config.step12.clobber = config.clobber;

% step 13: combine wm and csf mask
config.step13.skip = false;
config.step13.clobber = config.clobber;

% step 14: threshold wm and csf mask to keep intersect
config.step14.skip = false;
config.step14.thr = 2;
config.step14.clobber = config.clobber;

% step 15: multiply ventrical csf with wm csf boundary to trim edges
config.step15.skip = false;
config.step15.clobber = config.clobber;

% step 16: binarize and invert csf and wm overlap mask
config.step16.skip = false;
config.step16.clobber = config.clobber;

% step 17: multiply csf and wm overlap with gm mask to trim edges
config.step17.skip = false;
config.step17.clobber = config.clobber;

% step 18: erode the wm mask's outer parts to be sure that it is wm
config.step18.numErosions = 3;
config.step18.clobber = config.clobber;
config.step18.skip = false;

% step 19: erode the csf mask's outer parts to be sure that it is csf
config.step19.numErosions = 1;
config.step19.clobber = config.clobber;
config.step19.skip = false;

config.step20.skip = false;
config.step20.clobber = config.clobber;

config.step21.skip = false;
config.step21.clobber = config.clobber;

config.step22.skip = false;
config.step22.clobber = config.clobber;



end

