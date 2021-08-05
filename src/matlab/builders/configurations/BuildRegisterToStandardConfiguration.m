function [config] = BuildRegisterToStandardConfiguration()
%BUILDREGISTERTOSTANDARDCONFIGURATION Builds configuration for pipeline.
%   Builds a configuration for a pipeline that registers volumes to a standard.
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

%% pipeline: register to standard
% common configuration
config.verbose = true;
config.clobber = true;
config.pathToWorkspace = pathToWorkspace;
config.pathToDataset = pathToDataset;
config.pathToParcellations = pathToParcellations;
config.pathToOutput = pathToOutput;
% helps debug by not running all subjects
config.numSubjects = 1;


% step 1
config.step1.dof = 6;
config.step1.interp = 'spline';
config.step1.optional = false;
config.step1.clobber = config.clobber;
config.step1.verbose = config.verbose;
% step 2: flirt
config.step2.dof = 6;
config.step2.applyxfm = true;
config.step2.nosearch = true;
config.step2.interp = 'spline';
config.step2.optional = false;
config.step2.clobber = config.clobber;
config.step2.verbose = config.verbose;
% step 3
config.step3.optional = false;
config.step3.clobber = config.clobber;
config.step3.verbose = config.verbose;
% step 4
config.step4.dof = 12;
config.step4.interp = 'spline';
config.step4.optional = false;
config.step4.clobber = config.clobber;
config.step4.verbose = config.verbose;
% step 5
config.step5.dof = 12;
config.step5.applyxfm = true;
config.step5.nosearch = true;
config.step5.interp = 'spline';
config.step5.optional = false;
config.step5.clobber = config.clobber;
config.step5.verbose = config.verbose;
% step 6
config.step6.optional = false;
config.step6.clobber = config.clobber;
config.step6.verbose = config.verbose;
% step 7
config.step7.optional = false;
config.step7.clobber = config.clobber;
config.step7.verbose = config.verbose;
% step 8
config.step8.optional = false;
config.step8.clobber = config.clobber;
config.step8.verbose = config.verbose;

end
