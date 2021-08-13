% ensure variables are cleared
clearvars;

% ensure src/matlab and subfolders are in the path
filePath = fileparts(which(mfilename));
addpath(genpath(fullfile(filePath, '../../matlab')));

% build configuration
config = BuildSegmentationConfiguration();

pipeline = BuildSegmentationPipeline(config.parcellation, ...
                                     config.pathToWorkspace, ...
                                     config.pathToDataset, ...
                                     config.pathToOutput, ...
                                     config.pathToOutput, ...
                                     config.numSubjects, ...
                                     config);
                                   
pipelineExecution = pipeline.run();

