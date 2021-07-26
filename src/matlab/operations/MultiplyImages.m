function [status, result] = MultiplyImages(pathToWorkspace, ...
                                           params, ...
                                           config)
%MULTIPLYIMAGES Multiply two images.
%   Uses `fslmaths` with `mul` to multiply two images.
%
%   Input:
%   - pathToWorkspace:  Path to the workspace.
%   - params:           Parameters to be used in the operation.
%   - config:           Configuration to be used in the operation.
%
%   Output:
%   - status:  Status returned by system call.
%   - result:  Result returned by system call.

arguments
  pathToWorkspace char = '.'
  params.inputFile1 char
  params.inputFile2 char
  params.outputFile char
  config.verbose logical = false
end

fullInputFile1 = fullfile(pathToWorkspace, params.inputFile1);
fullInputFile2 = fullfile(pathToWorkspace, params.inputFile2);
fullOutputFile = fullfile(pathToWorkspace, params.outputFile);

command = 'fslmaths %s -mul %s %s';
sentence = sprintf(command, fullInputFile1, fullInputFile2, fullOutputFile);
[status, result] = CallSystem(sentence, config.verbose);

end
