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

%% pipeline: functional connectivity
% common configuration
config.verbose = true;
config.clobber = true;
config.pathToWorkspace = pathToWorkspace;
config.pathToDataset = pathToDataset;
config.pathToOutput = pathToOutput;
% helps debug by not running all subjects
config.numSubjects = 1;
config.parallel = false;
config.numPcaComponents = 5;

% sequence level configurations
config.sequence.startStep = 1;
% config.sequence.runOnly = [ 4 ]; %#ok<NBRAK>
config.sequence.noCleanUp = true;

% step 1: reorient to standard
config.step1.optional = false;
config.step1.skip = false;
config.step1.clobber = config.clobber;
config.step1.verbose = config.verbose;

% step 2: correct slice timing
config.step2.r = 1.205;
config.step2.d = 3;
config.step2.odd = true;
config.step2.optional = false;
config.step2.skip = false;
config.step2.clobber = config.clobber;
config.step2.verbose = config.verbose;

% step 3: extract brain
config.step3.type = 'F';
config.step3.optional = false;
config.step3.skip = false;
config.step3.clobber = config.clobber;
config.step3.verbose = config.verbose;

% step 4: correct motion
config.step4.plots = true;
config.step4.meanvol = true;
config.step4.optional = false;
config.step4.skip = false;
config.step4.clobber = config.clobber;
config.step4.verbose = config.verbose;

% step 5: compute mean volume
config.step5.optional = false;
config.step5.skip = false;
config.step5.clobber = config.clobber;
config.step5.verbose = config.verbose;

% step 6: extract brain from mean volume
config.step6.type = 'R';
config.step6.f = 0.4;
config.step6.m = true;
config.step6.optional = false;
config.step6.skip = false;
config.step6.clobber = config.clobber;
config.step6.verbose = config.verbose;

% step 7: apply mask
config.step7.optional = false;
config.step7.skip = false;
config.step7.clobber = config.clobber;
config.step7.verbose = config.verbose;

% step 8: perform linear image registration
config.step8.interp = 'spline';
config.step8.dof = 6;
config.step8.cost = 'normmi';
config.step8.optional = false;
config.step8.skip = false;
config.step8.clobber = config.clobber;
config.step8.verbose = config.verbose;

%% step 9
% apply linear transformation
config.step9.interp = 'nearestneighbour';
config.step9.applyxfm = true;
config.step9.nosearch = true;
config.step9.optional = false;
config.step9.skip = false;
config.step9.clobber = config.clobber;
config.step9.verbose = config.verbose;

%% step 10
% perform linear image registration
config.step10.cost = 'bbr';
config.step10.optional = false;
config.step10.skip = false;
config.step10.clobber = config.clobber;
config.step10.verbose = config.verbose;

%% step 11
% invert transformation matrix
config.step11.optional = false;
config.step11.skip = false;
config.step11.clobber = config.clobber;
config.step11.verbose = config.verbose;

%% step 12
% concatenate transformation matrices
config.step12.optional = false;
config.step12.skip = false;
config.step12.clobber = config.clobber;
config.step12.verbose = config.verbose;

%% step 13
% apply linear transformation to brain mask
config.step13.interp = 'nearestneighbour';
config.step13.applyxfm = true;
config.step13.nosearch = true;
config.step13.optional = false;
config.step13.skip = false;
config.step13.clobber = config.clobber;
config.step13.verbose = config.verbose;

%% step 14
% apply linear transformation to wm mask
config.step14.interp = 'nearestneighbour';
config.step14.applyxfm = true;
config.step14.nosearch = true;
config.step14.optional = false;
config.step14.skip = false;
config.step14.clobber = config.clobber;
config.step14.verbose = config.verbose;

%% step 15
% apply linear transformation to wm mask eroded
config.step15.interp = 'nearestneighbour';
config.step15.applyxfm = true;
config.step15.nosearch = true;
config.step15.optional = false;
config.step15.skip = false;
config.step15.clobber = config.clobber;
config.step15.verbose = config.verbose;

%% step 16
% apply linear transformation to csf mask
config.step16.interp = 'nearestneighbour';
config.step16.applyxfm = true;
config.step16.nosearch = true;
config.step16.optional = false;
config.step16.skip = false;
config.step16.clobber = config.clobber;
config.step16.verbose = config.verbose;

%% step 17
% apply linear transformation to csf mask eroded
config.step17.interp = 'nearestneighbour';
config.step17.applyxfm = true;
config.step17.nosearch = true;
config.step17.optional = false;
config.step17.skip = false;
config.step17.clobber = config.clobber;
config.step17.verbose = config.verbose;

%% step 18
% apply linear transformation to csfvent mask eroded
config.step18.interp = 'nearestneighbour';
config.step18.applyxfm = true;
config.step18.nosearch = true;
config.step18.optional = false;
config.step18.skip = false;
config.step18.clobber = config.clobber;
config.step18.verbose = config.verbose;

%% step 19
% apply linear transformation to gm mask
config.step19.interp = 'nearestneighbour';
config.step19.applyxfm = true;
config.step19.nosearch = true;
config.step19.optional = false;
config.step19.skip = false;
config.step19.clobber = config.clobber;
config.step19.verbose = config.verbose;

%% step 20
% apply linear transformation to gm parcellation
config.step20.interp = 'nearestneighbour';
config.step20.applyxfm = true;
config.step20.nosearch = true;
config.step20.optional = false;
config.step20.skip = false;
config.step20.clobber = config.clobber;
config.step20.verbose = config.verbose;

%% step 21
% apply gm mask to parcellation
config.step21.optional = false;
config.step21.skip = false;
config.step21.clobber = config.clobber;
config.step21.verbose = config.verbose;

%% step 22
% threshold clusters by voxel count
config.step22.threshold = 0;
config.step22.optional = false;
config.step22.skip = false;
config.step22.clobber = config.clobber;
config.step22.verbose = config.verbose;

%% step 23
% normalize intensity
config.step23.meanIntensity = 1000;
config.step23.optional = false;
config.step23.skip = false;
config.step23.clobber = config.clobber;
config.step23.verbose = config.verbose;

%% step 24
% fill brain mask
config.step24.optional = false;
config.step24.skip = false;
config.step24.clobber = config.clobber;
config.step24.verbose = config.verbose;

%% step 25
% detrend
config.step25.optional = false;
config.step25.skip = false;
config.step25.clobber = config.clobber;
config.step25.verbose = config.verbose;

%% step 26
% framewise displacement regressor
config.step26.metric = 'fd';
config.step26.thresh = 0.55;
config.step26.optional = false;
config.step26.skip = false;
config.step26.clobber = true;
config.step26.verbose = config.verbose;

%% step 27
% dvars regressor
config.step27.metric = 'dvars';
config.step27.optional = false;
config.step27.skip = false;
config.step27.clobber = config.clobber;
config.step27.verbose = config.verbose;

%% step 28
% std dev outliers
config.step28.optional = false;
config.step28.skip = false;
config.step28.clobber = config.clobber;
config.step28.verbose = config.verbose;

%% step 29
% csf vent pca
% we want numPcaComponents to be equal across analyses
config.step29.numPcaComponents = config.numPcaComponents;
config.step29.optional = false;
config.step29.skip = false;
config.step29.clobber = config.clobber;
config.step29.verbose = config.verbose;

%% step 30
% wm pca
% we want numPcaComponents to be equal across analyses
config.step30.numPcaComponents = config.numPcaComponents;
config.step30.optional = false;
config.step30.skip = false;
config.step30.clobber = config.clobber;
config.step30.verbose = config.verbose;

%% step 31
% gm pca
% we want numPcaComponents to be equal across analyses
config.step31.numPcaComponents = config.numPcaComponents;
config.step31.optional = false;
config.step31.skip = false;
config.step31.clobber = config.clobber;
config.step31.verbose = config.verbose;

%% step 32
% whole brain global signal
% we want numPcaComponents to be equal across analyses
config.step32.numPcaComponents = config.numPcaComponents;
config.step32.optional = false;
config.step32.skip = false;
config.step32.clobber = config.clobber;
config.step32.verbose = config.verbose;

end
