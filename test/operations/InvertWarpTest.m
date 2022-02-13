%% main function to generate tests

function tests = InvertWarpTest
  tests = functiontests(localfunctions);
end

%% test functions

function TestDefaultCommand(testCase)
 
  % specify (arbitrary) input files 
  pathToWorkspace = '.';
  warpVolume= 'warp.nii';
  outputVolume= 'output.nii';
  referenceVolume = 'reference.nii';
  
  % these two steps allow us to pass a struct to the operation
  config = struct('warpVolume', warpVolume, ...
   'outputVolume', outputVolume, ...
   'referenceVolume', referenceVolume, ...
   'abs', true, ...
   'rel', false, ...
   'debug', false, ...
   'd', false, ...
   'jmin', 0.01, ...
   'jmax', 100.0, ...
   'verbose', false);
  configCell = namedargs2cell(config);
  
  % run the operation to get the actual command
  [~, ~, actualCommand] = InvertWarp(pathToWorkspace, configCell{:});
  
  % this is the expected default command
  warpfield = fullfile(pathToWorkspace, warpVolume);
  outputfile = fullfile(pathToWorkspace, outputVolume);
  referencefile = fullfile(pathToWorkspace, referenceVolume);
  expectedCommand = ...
   sprintf('invwarp --warp=%s --ref=%s --out=%s --abs --jmin=0.0100 --jmax=100.0000', warpfield, referencefile, outputfile);
  
  % verify equality
  verifyEqual(testCase, actualCommand, expectedCommand);

end

function TestSpecifyingAllOptions(testCase)

  % specify (arbitrary) input files 
  pathToWorkspace = '.';
  warpVolume= 'warp.nii';
  outputVolume= 'output.nii';
  referenceVolume = 'reference.nii';
  
  % these two steps allow us to pass a struct to the operation
  config = struct('warpVolume', warpVolume, ...
   'outputVolume', outputVolume, ...
   'referenceVolume', referenceVolume, ...
   'abs', false, ...
   'rel', true, ...
   'debug', true, ...
   'd', true, ...
   'jmin', 0.05, ...
   'jmax', 110.0, ...
   'verbose', true);
  configCell = namedargs2cell(config);
  
  % run the operation to get the actual command
  [~, ~, actualCommand] = InvertWarp(pathToWorkspace, configCell{:});
  
  % this is the expected command with all options specified
  warpfield = fullfile(pathToWorkspace, warpVolume);
  outputfile = fullfile(pathToWorkspace, outputVolume);
  referencefile = fullfile(pathToWorkspace, referenceVolume);
  expectedCommand = ...
   sprintf('invwarp --warp=%s --ref=%s --out=%s --rel --jmin=0.0500 --jmax=110.0000 --debug -v', warpfield, referencefile, outputfile);
  
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
