%% main function to generate tests
function tests = CorrectMotionTest
  tests = functiontests(localfunctions);
end

%% test functions
function TestDefaultCommand(testCase)
  pathToWorkspace = '.';
  % these two steps allow us to pass a struct to the operation
  config = struct('inputVolume', 'sample.nii');
  configCell = namedargs2cell(config);
  
  % run the operation to get the actual command
  [~, ~, actualCommand] = CorrectMotion(pathToWorkspace, configCell{:});
  
  % this is the expected default command
  expectedCommand = 'mcflirt -in ./sample.nii';
  
  % verify equality
  verifyEqual(testCase, actualCommand, expectedCommand);
end

function TestSpecifyingAllOptions(testCase)
  pathToWorkspace = '.';
  % these two steps allow us to pass a struct to the operation
  config = struct('inputVolume', 'sample.nii', ...
                  'outputVolume', 'output.nii', ...
                  'plots', true, ...
                  'meanvol', true, ...
                  'verbose', true);
  configCell = namedargs2cell(config);
  
  % run the operation to get the actual command
  [~, ~, actualCommand] = CorrectMotion(pathToWorkspace, configCell{:});
  
  % this is the expected default command
  expectedCommand = 'mcflirt -in ./sample.nii -o ./output.nii -plots -meanvol -verbose 1 -report';
  
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
