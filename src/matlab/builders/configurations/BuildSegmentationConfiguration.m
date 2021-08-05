function [config] = BuildSegmentationConfiguration()
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
pathToWorkspace = fullfile(pathToDataFolder, 'w1');
pathToDataset = fullfile(pathToDataFolder, 'input');
pathToParcellations = fullfile(pathToDataFolder, 'parcs');
% for intermediary pipelines, send output to the transfer folder
pathToOutput = fullfile(pathToDataFolder, 'transfer');

%% pipeline: segmentation
% common configuration
config.verbose = true;
config.clobber = true;
config.pathToWorkspace = pathToWorkspace;
config.pathToDataset = pathToDataset;
config.pathToParcellations = pathToParcellations;
config.pathToOutput = pathToOutput;
% helps debug by not running all subjects
config.numSubjects = 1;


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
config.step4.optional = true;
config.step4.verbose = config.verbose;

% step 5: apply mask
config.step5.optional = true;
config.step5.verbose = config.verbose;

% step 6: invert subcortical mask
config.step6.optional = true;
config.step6.verbose = config.verbose;

% step 7: multiply segmented brain by inverted subcortical mask
config.step7.skip = true;
config.step7.verbose = config.verbose;

% step 8: tag subcortical mask as gray matter
config.step8.skip = true;
config.step8.verbose = config.verbose;

% step 9: add subcortical mask back to segmented brain
config.step9.skip = true;

% step 10: create tissue type masks
config.step10.skip = true;

% step 11: dilate wm mask
config.step11.skip = true;

% step 12: dilate csf mask
config.step12.skip = true;

% step 13: combine wm and csf mask
config.step13.skip = true;

% step 14: threshold wm and csf mask to keep intersect
config.step14 = struct(); %.skip = true;
config.step14.thr = 2;

% step 15: multiply ventrical csf with wm csf boundary to trim edges
config.step15.skip = false;

% step 16: binarize and invert csf and wm overlap mask
config.step16.skip = false;

% step 17: multiply csf and wm overlap with gm mask to trim edges
config.step16.skip = false;

% step 18: erode the wm mask's outer parts to be sure that it is wm
config.step18.numErosions = 3;
config.step18.skip = false;

% step 19: erode the csf mask's outer parts to be sure that it is csf
config.step19.numErosions = 1;
config.step19.skip = false;


end

