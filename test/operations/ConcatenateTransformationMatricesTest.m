%% main function to generate tests

function tests = ConcatenateTransformationMatricesTest
  tests = functiontests(localfunctions);
end

%% test functions

function TestDefaultCommand(testCase)
 
  % specify (arbitrary) input files 
  pathToWorkspace = '.';
  inputMatrix1 = 'inputmat1.mat';
  inputMatrix2 = 'inputmat2.mat';
  outputMatrix = 'outputmat.mat';
  
  % these two steps allow us to pass a struct to the operation
  config = struct('inputMatrix1', inputMatrix1, ...
   'inputMatrix2', inputMatrix2, ...
   'outputMatrix', outputMatrix, ...
   'verbose', false);
  configCell = namedargs2cell(config);
  
  % run the operation to get the actual command
  [~, ~, actualCommand] = ConcatenateTransformationMatrices(pathToWorkspace, configCell{:});
  
  % this is the expected default command
  inputmatrix1 = fullfile(pathToWorkspace, inputMatrix1);
  inputmatrix2 = fullfile(pathToWorkspace, inputMatrix2);
  outputmatrix = fullfile(pathToWorkspace, outputMatrix);
  expectedCommand = sprintf('convert_xfm -omat %s -concat %s %s', outputmatrix, inputmatrix1, inputmatrix2);
  
  % verify equality
  verifyEqual(testCase, actualCommand, expectedCommand);

end

function TestSpecifyingAllOptions(testCase)

  % specify (arbitrary) input files 
   pathToWorkspace = '.';
   inputMatrix1 = 'inputmat1.mat';
   inputMatrix2 = 'inputmat2.mat';
   outputMatrix = 'outputmat.mat';
   
   % these two steps allow us to pass a struct to the operation
   config = struct('inputMatrix1', inputMatrix1, ...
    'inputMatrix2', inputMatrix2, ...
    'outputMatrix', outputMatrix, ...
    'verbose', true);
   configCell = namedargs2cell(config);
   
   % run the operation to get the actual command
   [~, ~, actualCommand] = ConcatenateTransformationMatrices(pathToWorkspace, configCell{:});
   
   % this is the expected command with all options specified
   inputmatrix1 = fullfile(pathToWorkspace, inputMatrix1);
   inputmatrix2 = fullfile(pathToWorkspace, inputMatrix2);
   outputmatrix = fullfile(pathToWorkspace, outputMatrix);
   expectedCommand = sprintf('convert_xfm -omat %s -concat %s %s', outputmatrix, inputmatrix1, inputmatrix2);
   
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
