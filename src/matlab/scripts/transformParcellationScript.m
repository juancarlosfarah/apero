% ensure variables are cleared
clearvars;

% ensure src/matlab and subfolders are in the path
filePath = fileparts(which(mfilename));
addpath(genpath(fullfile(filePath, '../../matlab')));

% build configuration
parcellation = 'shen_MNI152';
config = BuildTransformParcellationConfiguration(parcellation);

pipeline = BuildTransformParcellationPipeline(config.parcellation, ...
                                              config.pathToWorkspace, ...
                                              config.pathToDataset, ...
                                              config.pathToParcellations, ...
                                              config.pathToOutput, ...
                                              config.pathToOutput, ...
                                              config.numSubjects, ...
                                              config);
                                           
pipelineExecution = pipeline.run();