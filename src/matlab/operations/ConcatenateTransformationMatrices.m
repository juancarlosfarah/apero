function [status, result, sentence] = ConcatenateTransformationMatrices(pathToWorkspace, config)
%CONCATENATETRANSFORMATIONMATRICES Concatenate two transformation matrices.
%   Uses `convert_xfm` with `concat` to concatenate transformation matrices.
%
%   Input:
%   - pathToWorkspace:  Path to the workspace.
%   - config:           Configuration to be used in the operation.
%
%   Output:
%   - status:  Status returned by system call.
%   - result:  Result returned by system call.

arguments
  pathToWorkspace char = '.'
  config.inputMatrix1 char = ''
  config.inputMatrix2 char = ''
  config.outputMatrix char = ''
  config.verbose logical = false
end

fullInputMatrix1 = fullfile(pathToWorkspace, config.inputMatrix1);
fullInputMatrix2 = fullfile(pathToWorkspace, config.inputMatrix2);
fullOutputMatrix = fullfile(pathToWorkspace, config.outputMatrix);

command = 'convert_xfm -omat %s -concat %s %s';
sentence = sprintf(command, ...
                   fullOutputMatrix, ...
                   fullInputMatrix1, ...
                   fullInputMatrix2);

[status, result] = CallSystem(sentence, config.verbose);

end
