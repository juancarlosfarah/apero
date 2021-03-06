% ensure variables are cleared
clearvars;

% ensure src/matlab and subfolders are in the path
filePath = fileparts(which(mfilename));
addpath(genpath(fullfile(filePath, '../../matlab')));

% get data folder relative to this file
pathToDataFolder = fullfile(filePath, '../../../../neurochi/data/');
pathToWorkspace = fullfile(pathToDataFolder, 'workspace');
pathToDataset = fullfile(pathToDataFolder, 'input');
pathToOutput = fullfile(pathToDataFolder, 'output');
scriptOutputFile = fullfile(pathToOutput, 'output.mat');

%% pipeline 1: brain extraction
config1 = BuildBrainExtractionConfiguration();
pipeline1 = BuildBrainExtractionPipeline(config1.pathToWorkspace, ...
                                         config1.pathToDataset, ...
                                         config1.pathToOutput, ...
                                         config1.numSubjects, ...
                                         config1);
pipelineExecution1 = pipeline1.run();


%% pipeline 2: register to standard
config2 = BuildRegisterToStandardConfiguration();
pipeline2 = BuildRegisterToStandardPipeline(config2.pathToWorkspace, ...
                                            config2.pathToDataset, ...
                                            config2.pathToParcellations, ...
                                            config2.pathToOutput, ...
                                            config2.pathToOutput, ...
                                            config2.numSubjects, ...
                                            config2);
pipelineExecution2 = pipeline2.run();


%% pipeline 3: transform parcellation
parcellation = 'shen_MNI152.nii.gz';
config3 = BuildTransformParcellationConfiguration(parcellation);
pipeline3 = BuildTransformParcellationPipeline(config3.parcellation, ...
                                               config3.pathToWorkspace, ...
                                               config3.pathToDataset, ...
                                               config3.pathToParcellations, ...
                                               config3.pathToOutput, ...
                                               config3.pathToOutput, ...
                                               config3.numSubjects, ...
                                               config3);
pipelineExecution3 = pipeline3.run();

%% pipeline 4: transform ventricle atlas
parcellation = 'mask_ventricles_MNIch2.nii.gz';
config4 = BuildTransformParcellationConfiguration(parcellation);
pipeline4 = BuildTransformParcellationPipeline(config4.parcellation, ...
                                               config4.pathToWorkspace, ...
                                               config4.pathToDataset, ...
                                               config4.pathToParcellations, ...
                                               config4.pathToOutput, ...
                                               config4.pathToOutput, ...
                                               config4.numSubjects, ...
                                               config4);
pipelineExecution4 = pipeline4.run();

%% pipeline 5: segment
parcellation = 'shen_MNI152';
config5 = BuildSegmentationConfiguration(parcellation);
pipeline5 = BuildSegmentationPipeline(config5.parcellation, ...
                                      config5.pathToWorkspace, ...
                                      config5.pathToDataset, ...
                                      config5.pathToOutput, ...
                                      config5.pathToOutput, ...
                                      config5.numSubjects, ...
                                      config5);
pipelineExecution5 = pipeline5.run();

%% pipeline 6: build functional connectome
config6 = BuildFunctionalConnectivityConfiguration();
pipeline6 = BuildFunctionalConnectivityPipeline(config6.pathToWorkspace, ...
                                                config6.pathToDataset, ...
                                                config6.pathToOutput, ...
                                                config6.pathToOutput, ...
                                                config6.numSubjects, ...
                                                config6);
pipelineExecution6 = pipeline6.run();

% save pipeline execution files
save(scriptOutputFile, ...
     'pipelineExecution1', ...
     'pipelineExecution2', ...
     'pipelineExecution3', ...
     'pipelineExecution4', ...
     'pipelineExecution5', ...
     'pipelineExecution6');
