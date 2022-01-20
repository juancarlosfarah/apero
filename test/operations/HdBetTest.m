%% main function to generate tests

function tests = HdBetTest
  tests = functiontests(localfunctions);
end

%% test functions

function TestDefaultCommand(testCase)

 % specify (arbitrary) input files 
 pathToWorkspace = '.';
 input = 'sample.nii';
 output = 'output.nii';
 
 % these two steps allow us to pass a struct to the operation
 config = struct('input', input, ...
  'output', output, ...
  'mode', 'fast', ...
  'device', 0, ...
  'tta', true, ...
  'pp', true, ...
  's', true, ...
  'verbose', false);
 configCell = namedargs2cell(config);
 
 % run the operation to get the actual command
 [~, ~, actualCommand] = HdBet(pathToWorkspace, configCell{:});
 
 % this is the expected default command
 inputfile = fullfile(pathToWorkspace, input);
 outputfile = fullfile(pathToWorkspace, output);
 expectedCommand = sprintf('hd-bet -i %s -o %s -mode fast -device 0 -tta 1 -pp 1 -s 1', inputfile, outputfile);
 
 % verify equality
 verifyEqual(testCase, actualCommand, expectedCommand);

end

function TestSpecifyingAllOptions(testCase)
 
 % specify (arbitrary) input files 
 pathToWorkspace = '.';
 input = 'sample.nii';
 output = 'output.nii';
 
 % these two steps allow us to pass a struct to the operation
 config = struct('input', input, ...
  'output', output, ...
  'mode', 'accurate', ...
  'device', 'cpu', ...
  'tta', false, ...
  'pp', false, ...
  's', false, ...
  'verbose', true);
 configCell = namedargs2cell(config);
 
 % run the operation to get the actual command
 [~, ~, actualCommand] = HdBet(pathToWorkspace, configCell{:});
 
 % this is the expected default command
 inputfile = fullfile(pathToWorkspace, input);
 outputfile = fullfile(pathToWorkspace, output);
 expectedCommand = sprintf('hd-bet -i %s -o %s -mode accurate -device cpu -tta 0 -pp 0 -s 0', inputfile, outputfile);
 
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
