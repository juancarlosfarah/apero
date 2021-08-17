function [config] = BuildFunctionalConnectivityConfiguration()
%BUILDFUNCTIONALCONNECTIVITYCONFIGURATION Builds configuration for a pipeline.
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
% for intermediary pipelines, send output to the transfer folder
pathToOutput = fullfile(pathToDataFolder, 'transfer');

%% pipeline: segmentation
% common configuration
config.verbose = true;
config.clobber = true;
config.pathToWorkspace = pathToWorkspace;
config.pathToDataset = pathToDataset;
config.pathToOutput = pathToOutput;
% helps debug by not running all subjects
config.numSubjects = 1;
config.parallel = false;

% sequence level configurations
config.sequence.startStep = 1;
config.sequence.noCleanUp = true;

% step 1: reorient to standard
config.step1.optional = false;
config.step1.skip = false;
config.step1.clobber = config.clobber;
config.step1.verbose = config.verbose;


end

