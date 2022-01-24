%% main function to generate tests

function tests = ProcessAnatomicalImageTest
  tests = functiontests(localfunctions);
end

%% test functions

function TestDefaultCommand(testCase)
 
  % specify (arbitrary) input files 
  pathToWorkspace = '.';
  inputFile = 'sample.nii';
  outputFolder = 'outputdir';
  
  % these two steps allow us to pass a struct to the operation
  config = struct('inputFile', inputFile, ...
   'outputFolder', outputFolder, ...
   'clobber', true, ...
   'noReg', true, ...
   'noNonLinReg', true, ...
   'noSeg', true, ...
   'weakBias', true, ...
   'noReorient', true, ...
   'noCrop', true, ...
   'verbose', false);
  configCell = namedargs2cell(config);
  
  % run the operation to get the actual command
  [~, ~, actualCommand] = ProcessAnatomicalImage(pathToWorkspace, configCell{:});
  
  % this is the expected default command
  inputfile = fullfile(pathToWorkspace, inputFile);
  outputdirectory = fullfile(pathToWorkspace, outputFolder);
  expectedCommand = ...
   sprintf('fsl_anat --clobber --noreg --nononlinreg --noseg --weakbias --noreorient --nocrop -i %s -o %s', ...
   inputfile, outputdirectory);
  
  % verify equality
  verifyEqual(testCase, actualCommand, expectedCommand);

end

function TestSpecifyingAllOptions(testCase)

  % specify (arbitrary) input files 
  pathToWorkspace = '.';
  inputFile = 'sample.nii';
  outputFolder = 'outputdir';
  
  % these two steps allow us to pass a struct to the operation
  config = struct('inputFile', inputFile, ...
   'outputFolder', outputFolder, ...
   'clobber', false, ...
   'noReg', false, ...
   'noNonLinReg', false, ...
   'noSeg', false, ...
   'weakBias', false, ...
   'noReorient', false, ...
   'noCrop', false, ...
   'verbose', true);
  configCell = namedargs2cell(config);
  
  % run the operation to get the actual command
  [~, ~, actualCommand] = ProcessAnatomicalImage(pathToWorkspace, configCell{:});
  
  % this is the expected default command
  inputfile = fullfile(pathToWorkspace, inputFile);
  outputdirectory = fullfile(pathToWorkspace, outputFolder);
  expectedCommand = sprintf('fsl_anat -i %s -o %s', inputfile, outputdirectory);
  
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
