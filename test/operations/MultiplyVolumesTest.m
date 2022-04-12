%% main function to generate tests

function tests = MultiplyVolumesTest
  tests = functiontests(localfunctions);
end

%% test functions

function TestDefaultCommand(testCase)

  % specify (arbitrary) input files 
  pathToWorkspace = '.';
  inputVolume1 = 'sample1.nii';
  inputVolume2 = 'sample2.nii';
  outputVolume = 'output.nii';

  % these two steps allow us to pass a struct to the operation
  config = struct('inputVolume1', inputVolume1, ...
   'inputVolume2', inputVolume2, ...
   'outputVolume', outputVolume, ...
   'verbose', false);
  configCell = namedargs2cell(config);

  % run the operation to get the actual command
  [~, ~, actualCommand] = MultiplyVolumes(pathToWorkspace, configCell{:});

  % this is the expected default command
  inputfile1 = fullfile(pathToWorkspace, inputVolume1);
  inputfile2 = fullfile(pathToWorkspace, inputVolume2);
  outputfile = fullfile(pathToWorkspace, outputVolume);
  expectedCommand = sprintf('fslmaths %s -mul %s %s', inputfile1, inputfile2, outputfile);
  
  % verify equality
  verifyEqual(testCase, actualCommand, expectedCommand);
  
end

function TestSpecifyingAllOptions(testCase)
  
  % specify (arbitrary) input files 
  pathToWorkspace = '.';
  inputVolume1 = 'sample1.nii';
  inputVolume2 = 'sample2.nii';
  outputVolume = 'output.nii';

  % these two steps allow us to pass a struct to the operation
  config = struct('inputVolume1', inputVolume1, ...
   'inputVolume2', inputVolume2, ...
   'outputVolume', outputVolume, ...
   'verbose', true);
  configCell = namedargs2cell(config);

  % run the operation to get the actual command
  [~, ~, actualCommand] = MultiplyVolumes(pathToWorkspace, configCell{:});

  % this is the expected command with verbose option
  inputfile1 = fullfile(pathToWorkspace, inputVolume1);
  inputfile2 = fullfile(pathToWorkspace, inputVolume2);
  outputfile = fullfile(pathToWorkspace, outputVolume);
  expectedCommand = sprintf('fslmaths %s -mul %s %s', inputfile1, inputfile2, outputfile);
  
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
