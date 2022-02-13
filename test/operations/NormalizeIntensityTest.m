%% main function to generate tests

function tests = NormalizeIntensityTest
  tests = functiontests(localfunctions);
end

%% test functions

function TestDefaultCommand(testCase)

  % specify (arbitrary) input files 
  pathToWorkspace = '.';
  inputVolume = 'sample.nii';
  outputVolume = 'output.nii';

  % these two steps allow us to pass a struct to the operation
  config = struct('inputVolume', inputVolume, ...
   'outputVolume', outputVolume, ...
   'meanIntensity', 1000, ...
   'verbose', false);
  configCell = namedargs2cell(config);

  % run the operation to get the actual command
  [~, ~, actualCommand] = NormalizeIntensity(pathToWorkspace, configCell{:});

  % this is the expected default command
  inputfile = fullfile(pathToWorkspace, inputVolume);
  outputfile = fullfile(pathToWorkspace, outputVolume);
  expectedCommand = sprintf('fslmaths %s -ing 1000 %s', inputfile, outputfile);
  
  % verify equality
  verifyEqual(testCase, actualCommand, expectedCommand);
  
end

function TestSpecifyingAllOptions(testCase)
  
  % specify (arbitrary) input files 
  pathToWorkspace = '.';
  inputVolume = 'sample.nii';
  outputVolume = 'output.nii';

  % these two steps allow us to pass a struct to the operation
  config = struct('inputVolume', inputVolume, ...
   'outputVolume', outputVolume, ...
   'meanIntensity', 1200, ...
   'verbose', true);
  configCell = namedargs2cell(config);

  % run the operation to get the actual command
  [~, ~, actualCommand] = NormalizeIntensity(pathToWorkspace, configCell{:});

  % this is the expected command with verbose option
  inputfile = fullfile(pathToWorkspace, inputVolume);
  outputfile = fullfile(pathToWorkspace, outputVolume);
  expectedCommand = sprintf('fslmaths %s -ing 1200 %s', inputfile, outputfile);
  
  % verify equality
  verifyEqual(testCase, actualCommand, expectedCommand);
  
end

%% optional file fixtures

function setupOnce(testCase)
  % do not change function name
  % use to set a new path, for example
end

function teardownOnce(testCase)
  % do not change function name
  % use to change back to original path, for example
end

%% optional fresh fixtures

function setup(testCase)
  % do not change function name
  % use to open a figure, for example
end

function teardown(testCase)
  % do not change function name
  % use to close a figure, for example
end
