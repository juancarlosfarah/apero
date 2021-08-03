% ensure variables are cleared
clearvars;

% ensure src/matlab and subfolders are in the path
filePath = fileparts(which(mfilename));
addpath(genpath(fullfile(filePath, '../../matlab')));

% build configuration
config = BuildSampleConfiguration();

pipeline = BuildSegmentationPipeline(config.common.pathToWorkspace, ...
                                     config.common.pathToDataset, ...
                                     config.pipeline1.pathToOutput, ...
                                     config.pipeline3.pathToOutput, ...
                                     config.common.numSubjects, ...
                                     config.pipeline3);
                                   
pipelineExecution = pipeline.run();
