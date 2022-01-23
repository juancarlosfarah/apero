%% main function to generate tests

function tests = PerformNonLinearImageRegistrationTest
  tests = functiontests(localfunctions);
end

%% test functions

function TestDefaultCommand(testCase)

  % specify (arbitrary) input files 
  pathToWorkspace = '.';
  inputImage = 'sample.nii';
  referenceImage = 'reference.nii';
  
  % these two steps allow us to pass a struct to the operation
  config = struct('inputImage', inputImage, ...
   'referenceImage', referenceImage, ...
   'outputImage', '', ...
   'outputFieldCoefficients', '', ...
   'interp', 'linear', ....
   'verbose', false);
  configCell = namedargs2cell(config);
  
  % run the operation to get the actual command
  [~, ~, actualCommand] = PerformNonLinearImageRegistration(pathToWorkspace, configCell{:});
  
  % this is the expected default command
  inputfile = fullfile(pathToWorkspace, inputImage);
  referencefile = fullfile(pathToWorkspace, referenceImage);
  expectedCommand = sprintf('fnirt --in=%s --ref=%s --interp=linear', inputfile, referencefile);
  
  % verify equality
  verifyEqual(testCase, actualCommand, expectedCommand);

end

function TestSpecifyingAllOptions(testCase)
 
  % specify (arbitrary) input files 
  pathToWorkspace = '.';
  inputImage = 'sample.nii';
  referenceImage = 'reference.nii';
  outputImage = 'outputImage.nii';
  outputFieldCoefficients = 'outputFieldCoefficients.nii';
  
  % these two steps allow us to pass a struct to the operation
  config = struct('inputImage', inputImage, ...
   'referenceImage', referenceImage, ...
   'outputImage', outputImage, ...
   'outputFieldCoefficients', outputFieldCoefficients, ...
   'interp', 'spline', ....
   'verbose', true);
  configCell = namedargs2cell(config);
  
  % run the operation to get the actual command
  [~, ~, actualCommand] = PerformNonLinearImageRegistration(pathToWorkspace, configCell{:});
  
  % this is the expected default command
  inputfile = fullfile(pathToWorkspace, inputImage);
  referencefile = fullfile(pathToWorkspace, referenceImage);
  outputImagefile = fullfile(pathToWorkspace, outputImage);
  outputFieldCoefficientsfile = fullfile(pathToWorkspace, outputFieldCoefficients);
  expectedCommand = sprintf('fnirt --in=%s --ref=%s --iout=%s --cout=%s --interp=spline -v', ...
   inputfile, referencefile, outputImagefile, outputFieldCoefficientsfile);
  
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
