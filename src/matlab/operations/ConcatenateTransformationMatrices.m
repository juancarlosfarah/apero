function [status, result] = ConcatenateTransformationMatrices(pathToWorkspace, ...
                                                              params, ...
                                                              config)
%CONCATENATETRANSFORMATIONMATRICES Concatenate two transformation matrices.
%   Uses `convert_xfm` with `concat` to concatenate transformation matrices.
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
  params.inputMatrix1 char = ''
  params.inputMatrix2 char = ''
  params.outputMatrix char = ''
  config.verbose logical = false
end

fullInputMatrix1 = fullfile(pathToWorkspace, params.inputMatrix1);
fullInputMatrix2 = fullfile(pathToWorkspace, params.inputMatrix2);
fullOutputMatrix = fullfile(pathToWorkspace, params.outputMatrix);

command = 'convert_xfm -omat %s -concat %s %s';
sentence = sprintf(command, ...
                   fullOutputMatrix, ...
                   fullInputMatrix1, ...
                   fullInputMatrix2);

[status, result] = CallSystem(sentence, config.verbose);

end
