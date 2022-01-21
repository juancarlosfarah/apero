%% main function to generate tests

function tests = ExtractBrainTest
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
  'o', false, ...
  'm', false, ...
  's', false, ...
  'n', false, ...
  'f', 0.5, ...
  'g', 0, ...
  't', false, ...
  'e', false, ...
  'debug', false, ...
  'verbose', false);
 configCell = namedargs2cell(config);
 
 % run the operation to get the actual command
 [~, ~, actualCommand] = ExtractBrain(pathToWorkspace, configCell{:});
 
 % this is the expected default command
 inputfile = fullfile(pathToWorkspace, inputVolume);
 outputfile = fullfile(pathToWorkspace, outputVolume);
 expectedCommand = sprintf('bet %s %s -f 0.5000', inputfile, outputfile);
 
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
  'type', 'R', ...
  'o', true, ...
  'm', true, ...
  's', true, ...
  'n', true, ...
  'f', 0.6, ...
  'g', 0.2, ...
  't', true, ...
  'e', true, ...
  'debug', true, ...
  'verbose', true);
 configCell = namedargs2cell(config);
 
 % run the operation to get the actual command
 [~, ~, actualCommand] = ExtractBrain(pathToWorkspace, configCell{:});
 
 % this is the expected default command
 inputfile = fullfile(pathToWorkspace, inputVolume);
 outputfile = fullfile(pathToWorkspace, outputVolume);
 expectedCommand = sprintf('bet %s %s -R -o -m -s -n -f 0.6000 -g 0.2000 -t -e -v -d', ...
                                                inputfile, outputfile);
 
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
