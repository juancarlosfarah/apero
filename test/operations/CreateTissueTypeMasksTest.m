%% main function to generate tests

function tests = CreateTissueTypeMasksTest
  tests = functiontests(localfunctions);
end

%% test functions

function TestDefaultCommand(testCase)

  % specify (arbitrary) input files 
  pathToWorkspace = '.';
  inputVolume = 'sample.nii';
  
  % these two steps allow us to pass a struct to the operation
  config = struct('inputVolume', inputVolume, ...
   'tissueTypeLabels', {{'csf', 'gm', 'wm'}}, ...
   'startTypeValue', 1, ...
   'endTypeValue', 3, ...
   'verbose', false);
  configCell = namedargs2cell(config);

  % run the operation to get the actual command
  [~, ~, actualCommands] = CreateTissueTypeMasks(pathToWorkspace, configCell{:});

  % these are the expected default commands
  inputfile = fullfile(pathToWorkspace, inputVolume);
  outputfile1 = fullfile(pathToWorkspace, 'T1w_csf_mask.nii.gz');
  outputfile2 = fullfile(pathToWorkspace, 'T1w_gm_mask.nii.gz');
  outputfile3 = fullfile(pathToWorkspace, 'T1w_wm_mask.nii.gz');
  expectedCommands = {sprintf('fslmaths %s -thr 1 -uthr 1 -div 1 %s', inputfile, outputfile1), ...
   sprintf('fslmaths %s -thr 2 -uthr 2 -div 2 %s', inputfile, outputfile2), ...
   sprintf('fslmaths %s -thr 3 -uthr 3 -div 3 %s', inputfile, outputfile3)};
  
  % verify equality
  verifyEqual(testCase, actualCommands, expectedCommands);
  
end

function TestSpecifyingAllOptions(testCase)
  
  % specify (arbitrary) input files 
  pathToWorkspace = '.';
  inputVolume = 'sample.nii';
  
  % these two steps allow us to pass a struct to the operation
  config = struct('inputVolume', inputVolume, ...
   'tissueTypeLabels', {{'csf', 'wm'}}, ...
   'startTypeValue', 1, ...
   'endTypeValue', 2, ...
   'verbose', true);
  configCell = namedargs2cell(config);

  % run the operation to get the actual command
  [~, ~, actualCommands] = CreateTissueTypeMasks(pathToWorkspace, configCell{:});

  % these are the expected commands with all options specified
  inputfile = fullfile(pathToWorkspace, inputVolume);
  outputfile1 = fullfile(pathToWorkspace, 'T1w_csf_mask.nii.gz');
  outputfile2 = fullfile(pathToWorkspace, 'T1w_wm_mask.nii.gz');
  expectedCommands = {sprintf('fslmaths %s -thr 1 -uthr 1 -div 1 %s', inputfile, outputfile1), ...
   sprintf('fslmaths %s -thr 2 -uthr 2 -div 2 %s', inputfile, outputfile2)};

  % verify equality
  verifyEqual(testCase, actualCommands, expectedCommands);
  
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
