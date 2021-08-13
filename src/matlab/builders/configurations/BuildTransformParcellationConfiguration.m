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
% usually you use first a parcellation and then a ventricle atlas
% e.g. 'mask_ventricles_MNIch2.nii.gz'
config.parcellation = 'schaefer_2018_400_subc.nii';

% step 1: dilate parcellaton
config.step1.numDilations = 1;
config.step1.skip = false;
config.step1.clobber = config.clobber;
config.step1.verbose = config.verbose;

% step 2: apply inverse warp to go down to dof 12
config.step2.interp = 'nn';
config.step2.skip = false;
config.step2.clobber = config.clobber;
config.step2.verbose = config.verbose;

% step 3: apply inverted dof 12 transform to go down to dof 6
config.step3.interp = 'nearestneighbour';
config.step3.applyxfm = true;
config.step3.nosearch = true;
config.step3.optional = true;
config.step3.skip = false;
config.step3.clobber = config.clobber;
config.step3.verbose = config.verbose;

% step 4: apply inverted dof 6 transform to go down to native
config.step4.interp = 'nearestneighbour';
config.step4.applyxfm = true;
config.step4.nosearch = true;
config.step4.optional = true;
config.step4.skip = false;
config.step4.clobber = config.clobber;
config.step4.verbose = config.verbose;


end

