%% main function to generate tests

function tests = PerformLinearImageRegistrationTest
  tests = functiontests(localfunctions);
end

%% test functions

function TestDefaultCommand(testCase)

 % specify (arbitrary) input files 
 pathToWorkspace = '.';
 inputVolume = 'sample.nii';
 referenceVolume = 'reference.nii';
 
 % these two steps allow us to pass a struct to the operation
 config = struct('inputVolume', inputVolume, ...
  'referenceVolume', referenceVolume, ...
  'outputVolume', '', ...
  'outputMatrix', '', ...
  'initMatrix', '', ...
  'dof', 12, ...
  'applyxfm', false, ...
  'nosearch', false, ...
  'interp', 'trilinear', ...
  'cost', 'corratio', ...
  'verbose', false);
 configCell = namedargs2cell(config);
 
 % run the operation to get the actual command
 [~, ~, actualCommand] = PerformLinearImageRegistration(pathToWorkspace, configCell{:});
 
 % this is the expected default command
 inputfile = fullfile(pathToWorkspace, inputVolume);
 referencefile = fullfile(pathToWorkspace, referenceVolume);
 expectedCommand = sprintf('flirt -in %s -ref %s -dof 12 -interp trilinear -cost corratio', inputfile, referencefile);
 
 % verify equality
 verifyEqual(testCase, actualCommand, expectedCommand);

end

function TestSpecifyingInitMatrix(testCase)
 
  % specify (arbitrary) input files 
 pathToWorkspace = '.';
 inputVolume = 'sample.nii';
 referenceVolume = 'reference.nii';
 outputVolume = 'output.nii';
 initMatrix = 'initmat.mat';
 
 % these two steps allow us to pass a struct to the operation
 config = struct('inputVolume', inputVolume, ...
  'referenceVolume', referenceVolume, ...
  'outputVolume', outputVolume, ...
  'outputMatrix', '', ...
  'initMatrix', initMatrix, ...
  'dof', 6, ...
  'applyxfm', true, ...
  'nosearch', true, ...
  'interp', 'spline', ...
  'cost', 'mutualinfo', ...
  'verbose', true);
 configCell = namedargs2cell(config);
 
 % run the operation to get the actual command
 [~, ~, actualCommand] = PerformLinearImageRegistration(pathToWorkspace, configCell{:});
 
 % this is the expected default command
 inputfile = fullfile(pathToWorkspace, inputVolume);
 referencefile = fullfile(pathToWorkspace, referenceVolume);
 initmat = fullfile(pathToWorkspace, initMatrix);
 outputfile = fullfile(pathToWorkspace, outputVolume);

 expectedCommand = ...
  sprintf('flirt -in %s -ref %s -init %s -o %s -dof 6 -interp spline -cost mutualinfo -applyxfm -nosearch -v', ...
  inputfile, referencefile, initmat, outputfile);
 
 % verify equality
 verifyEqual(testCase, actualCommand, expectedCommand);

end

function TestUsingBbrOption(testCase)
 
  % specify (arbitrary) input files 
 pathToWorkspace = '.';
 inputVolume = 'sample.nii';
 referenceVolume = 'reference.nii';
 outputVolume = 'output.nii';
 outputMatrix = 'outputmat.mat';
 wmseg = 'wmseg.nii';
 wmcoords = 'wmcoords.mat';
 wmnorms = 'wmnorms.mat';
 
 % these two steps allow us to pass a struct to the operation
 config = struct('inputVolume', inputVolume, ...
  'referenceVolume', referenceVolume, ...
  'outputVolume', outputVolume, ...
  'outputMatrix', outputMatrix, ...
  'initMatrix', '', ...
  'dof', 12, ...
  'applyxfm', false, ...
  'nosearch', false, ...
  'interp', 'spline', ...
  'cost', 'bbr', ...
  'wmseg', wmseg, ...
  'wmcoords', wmcoords, ...
  'wmnorms', wmnorms, ...
  'verbose', true);
 configCell = namedargs2cell(config);
 
 % run the operation to get the actual command
 [~, ~, actualCommand] = PerformLinearImageRegistration(pathToWorkspace, configCell{:});
 
 % this is the expected default command
 inputfile = fullfile(pathToWorkspace, inputVolume);
 referencefile = fullfile(pathToWorkspace, referenceVolume);
 outputfile = fullfile(pathToWorkspace, outputVolume);
 outputmatfile = fullfile(pathToWorkspace, outputMatrix);
 wmsegfile = fullfile(pathToWorkspace, wmseg);
 wmcoordsfile = fullfile(pathToWorkspace, wmcoords);
 wmnormsfile = fullfile(pathToWorkspace, wmnorms);

 expectedCommand = ...
  sprintf('flirt -in %s -ref %s -o %s -omat %s -dof 12 -interp spline -cost bbr -wmseg %s -wmcoords %s -wmnorms %s -v', ...
  inputfile, referencefile, outputfile, outputmatfile, wmsegfile, wmcoordsfile, wmnormsfile);
 
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
