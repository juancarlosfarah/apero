% ensure variables are cleared
clearvars;

% build configuration
config = BuildSampleConfiguration();

pipeline = BuildSamplePipeline(config.common.pathToWorkspace, ...
                               config.common.pathToDataset, ...
                               config.common.pathToOutput, ...
                               config.common.numSubjects, ...
                               config.t1);

pipelineExecution = pipeline.run();