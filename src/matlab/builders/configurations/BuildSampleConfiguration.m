function [config] = BuildSampleConfiguration()
%BUILDSAMPLECONFIGURATION Summary of this function goes here
%   Detailed explanation goes here
%
%   Input:
%   - config: Base configuration.
%
%   Output:
%   - config: Configuiration.


config = {};

% get data folder relative to this file
filePath = fileparts(which(mfilename));
pathToDataFolder = fullfile(filePath, '../../../../../neurochi/data/');
pathToWorkspace = fullfile(pathToDataFolder, 'w1');
pathToDataset = fullfile(pathToDataFolder, 'input');
pathToParcellations = fullfile(pathToDataFolder, 'parcs');

% common configuration goes on a common object
common.verbose = true;
common.pathToWorkspace = pathToWorkspace;
common.pathToDataset = pathToDataset;
common.pathToParcellations = pathToParcellations;
common.numSubjects = 1;
config.common = common;

% best practice is to then build an object that you can pass to one or more
% sequences that contains all the sequence configuration
t1 = {};
t1.pathToOutput = fullfile(pathToDataFolder, 'o1');

% inherit
t1.verbose = common.verbose;

% provide step-specific configurations
t1.bet.type = 'R';
t1.bet.f = 0.4;
t1.bet.m = true;

% step configurations can also inherit from the sequence configurations
t1.bet.verbose = t1.verbose;

% you can also order this by pipeline / step
%% pipeline 2: register parcellations
pipeline2 = {};
pipeline2.verbose = common.verbose;
pipeline2.pathToOutput = fullfile(pathToDataFolder, 'o2');
% step 1
pipeline2.step1.dof = 6;
pipeline2.step1.interp = 'spline';
pipeline2.step1.optional = true;
pipeline2.step1.verbose = pipeline2.verbose;
% step 2
pipeline2.step2.dof = 6;
pipeline2.step2.applyxfm = true;
pipeline2.step2.nosearch = true;
pipeline2.step2.interp = 'spline';
pipeline2.step2.optional = true;
pipeline2.step2.verbose = pipeline2.verbose;
% step 3
pipeline2.step3.optional = true;
pipeline2.step3.verbose = pipeline2.verbose;
% step 4
pipeline2.step4.dof = 12;
pipeline2.step4.interp = 'spline';
pipeline2.step4.optional = true;
pipeline2.step4.verbose = pipeline2.verbose;
% step 5
pipeline2.step5.dof = 12;
pipeline2.step5.applyxfm = true;
pipeline2.step5.nosearch = true;
pipeline2.step5.interp = 'spline';
pipeline2.step5.optional = true;
pipeline2.step5.verbose = pipeline2.verbose;
% step 6
pipeline2.step6.optional = true;
pipeline2.step6.verbose = pipeline2.verbose;
% step 7
pipeline2.step7.optional = true;
pipeline2.step7.verbose = pipeline2.verbose;
% step 8
pipeline2.step8.optional = true;
pipeline2.step8.verbose = pipeline2.verbose;
% step 9
pipeline2.step9.numDilations = 2;
pipeline2.step9.optional = true;
pipeline2.step9.verbose = pipeline2.verbose;
% step 10
pipeline2.step10.interp = 'nn';
pipeline2.step10.optional = true;
pipeline2.step10.verbose = pipeline2.verbose;
% step 11
pipeline2.step11.interp = 'nearestneighbour';
pipeline2.step11.applyxfm = true;
pipeline2.step11.nosearch = true;
pipeline2.step11.optional = true;
pipeline2.step11.verbose = pipeline2.verbose;
% step 12
pipeline2.step12.interp = 'nearestneighbour';
pipeline2.step12.applyxfm = true;
pipeline2.step12.nosearch = true;
pipeline2.step12.optional = true;
pipeline2.step12.verbose = pipeline2.verbose;


% %% prepare fmri configuration object
%
% fmri.acquisitionType = 'interleaved';       % way z slices were acquired (sequential, interleaved)
% fmri.temporalResolution = 1.205;            % temporal resoltion of acquisition (verify with `mrinfo`)
% fmri.framewiseDisplacementThreshold = 0.55; % threshold used for motion outliers detection using framewise displacement
% fmri.dvarsThreshold = false;                % threshold used for motion outliers detection using dvars
% fmri.stdDevThreshold = false;               % threshold used for std dev outlier detection
% fmri.numPcaComponents = 5;                  % number of PCA components to consider
% fmri.outlierThreshold = 0.5;                % regress only if less than this threshold of outliers
% fmri.meanIntensity = 1000;                  % for intensity normalization according to (Power et al., 2014)
% fmri.fMin = .01; % MIPLAB configs
% fmri.fMax = .25; % task bandpass
% fmri.fhwm = 0; % Full Width at Half Maximum of the Gaussian kernel
% 
% config.fmri = fmri;

config.t1 = t1;
config.pipeline2 = pipeline2;

end

