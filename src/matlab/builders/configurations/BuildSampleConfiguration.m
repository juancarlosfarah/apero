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
%% pipeline 1: t1a
pipeline1 = {};
pipeline1.pathToOutput = fullfile(pathToDataFolder, 'o1');
pipeline1.verbose = common.verbose;

% provide step-specific configurations
% step 1: denoise
pipeline1.step1.verbose = pipeline1.verbose;
pipeline1.step1.optional = true;
% step 2: fsl_anat
pipeline1.step2.clobber = true;
% step 3: bet
pipeline1.step3.type = 'R';
pipeline1.step3.f = 0.4;
pipeline1.step3.m = true;
pipeline1.step3.optional = true;
% step configurations can also inherit from the sequence configurations
pipeline1.step3.verbose = pipeline1.verbose;

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
% step 2: flirt 
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

%% pipeline 3: segmentation
pipeline3 = {};
pipeline3.verbose = common.verbose;
pipeline3.pathToOutput = fullfile(pathToDataFolder, 'o3');
pipeline3.parallel = false;

% step 1: fast
pipeline3.step1.H = 0.25;
pipeline3.step1.clobber = false;
pipeline3.step1.optional = true;
pipeline3.step1.verbose = pipeline3.verbose;

% step 2: threshold
pipeline3.step2.thr = 1;
pipeline3.step2.uthr = 1;
pipeline3.step2.optional = true;
pipeline3.step2.verbose = pipeline3.verbose;

% step 3: invert
pipeline3.step3.clobber = false;
pipeline3.step3.optional = true;
pipeline3.step3.verbose = pipeline3.verbose;

% step 4: binarize
pipeline3.step4.verbose = pipeline3.verbose;


%% prepare fmri configuration object
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

config.pipeline1 = pipeline1;
config.pipeline2 = pipeline2;
config.pipeline3 = pipeline3;


end

