%% main function to generate tests

function tests = CreateSegmentationTest
  tests = functiontests(localfunctions);
end

%% test functions

function TestDefaultCommand(testCase)

  % specify (arbitrary) input files 
  pathToWorkspace = '.';
  inputVolume = 'sample.nii';
  out = 'output';

  % these two steps allow us to pass a struct to the operation
  config = struct('inputVolume', inputVolume, ...
                          'out', out, ...
                          't', 1, ...
                          'n', 3, ...
                          'H', 0.1, ...
                          'B', false, ...
                          'verbose', false);
  configCell = namedargs2cell(config);

 % run the operation to get the actual command
 [~, ~, actualCommand] = CreateSegmentation(pathToWorkspace, configCell{:});
 
 % this is the expected default command
 inputfile = fullfile(pathToWorkspace, inputVolume);
 outputfile = fullfile(pathToWorkspace, out);
 expectedCommand = sprintf('fast --out=%s -t 1 -n 3 -H 0.1000 %s', outputfile, inputfile);
 
 % verify equality
 verifyEqual(testCase, actualCommand, expectedCommand);

end

function TestSpecifyingAllOptions(testCase)

 % specify (arbitrary) input files 
 pathToWorkspace = '.';
 inputVolume = 'sample.nii';
 out = 'output';
 
 % these two steps allow us to pass a struct to the operation
 config = struct('inputVolume', inputVolume, ...
                         'out', out, ...
                         't', 3, ...
                         'n', 2, ...
                         'H', 0.2, ...
                         'B', true, ...
                         'verbose', true);
 configCell = namedargs2cell(config);
 
 % run the operation to get the actual command
 [~, ~, actualCommand] = CreateSegmentation(pathToWorkspace, configCell{:});
 
 % this is the expected default command
 inputfile = fullfile(pathToWorkspace, inputVolume);
 outputfile = fullfile(pathToWorkspace, out);
 expectedCommand = sprintf('fast --out=%s -t 3 -n 2 -H 0.2000 -B -v %s', outputfile, inputfile);
 
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
