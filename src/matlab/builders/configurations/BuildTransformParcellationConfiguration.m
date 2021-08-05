function [config] = BuildTransformParcellationConfiguration()
%BUILDTRANSFORMPARCELLATIONCONFIGURATION Builds configuration for pipeline.
%   Builds a configuration for a pipeline that transforms a parcellation.
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

%% pipeline: transform parcellation
% common configuration
config.verbose = true;
config.clobber = true;
config.pathToWorkspace = pathToWorkspace;
config.pathToDataset = pathToDataset;
config.pathToParcellations = pathToParcellations;
config.pathToOutput = pathToOutput;
% helps debug by not running all subjects
config.numSubjects = 1;
% select the parcellation to transform
% (must be present in `pathToParcellations`)
config.parcellation = 'mask_ventricles_MNIch2.nii.gz';

% step 1
config.step1.numDilations = 0;
config.step1.clobber = config.clobber;
config.step1.verbose = config.verbose;
% step 2
config.step2.interp = 'nn';
config.step2.clobber = config.clobber;
config.step2.verbose = config.verbose;
% step 3
config.step3.interp = 'nearestneighbour';
config.step3.applyxfm = true;
config.step3.nosearch = true;
config.step3.optional = true;
config.step3.clobber = config.clobber;
config.step3.verbose = config.verbose;

% step 4
config.step4.interp = 'nearestneighbour';
config.step4.applyxfm = true;
config.step4.nosearch = true;
config.step4.optional = true;
config.step4.clobber = config.clobber;
config.step4.verbose = config.verbose;


end

