% ensure variables are cleared
clearvars;

% ensure src/matlab and subfolders are in the path
filePath = fileparts(which(mfilename));
addpath(genpath(fullfile(filePath, '../../matlab')));

% build configuration
config = BuildBrainExtractionConfiguration();

pipeline = BuildBrainExtractionPipeline(config.pathToWorkspace, ...
                                        config.pathToDataset, ...
                                        config.pathToOutput, ...
                                        config.numSubjects, ...
                                        config);

pipelineExecution = pipeline.run();