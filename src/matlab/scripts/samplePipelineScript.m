% ensure variables are cleared
clearvars;

% get data folder relative to this file
filePath = fileparts(which(mfilename));
pathToDataFolder = fullfile(filePath, '../../../../neurochi/data/');


pathToWorkspace = fullfile(pathToDataFolder, 'w1');
pathToDataset = fullfile(pathToDataFolder, 'input');
pathToOutput = fullfile(pathToDataFolder, 'o1');
pipeline = BuildSamplePipeline(pathToWorkspace, ...
                               pathToDataset, ...
                               pathToOutput, ...
                               1);

outputs = pipeline.run();