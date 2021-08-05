function [status, result] = InvertTransformationMatrix(pathToWorkspace, ...
                                                       params, ...
                                                       config)
%INVERTTRANSFORMATIONMATRIX Invert a transformation matrix.
%   Uses `convert_xfm` with `inverse` to invert a transformation matrix.
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
  params.inputMatrix char = ''
  params.outputMatrix char = ''
  config.verbose logical = false
end

fullInputMatrix = fullfile(pathToWorkspace, params.inputMatrix);
fullOutputMatrix = fullfile(pathToWorkspace, params.outputMatrix);

command = 'convert_xfm -omat %s -inverse %s';
sentence = sprintf(command, fullOutputMatrix, fullInputMatrix);
[status, result] = CallSystem(sentence, config.verbose);

end
