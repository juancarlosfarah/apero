function [status, result, sentence] = InvertTransformationMatrix(pathToWorkspace, config)
%INVERTTRANSFORMATIONMATRIX Invert a transformation matrix.
%   Uses `convert_xfm` with `inverse` to invert a transformation matrix.
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
  config.inputMatrix char = ''
  config.outputMatrix char = ''
  config.verbose logical = false
end

fullInputMatrix = fullfile(pathToWorkspace, config.inputMatrix);
fullOutputMatrix = fullfile(pathToWorkspace, config.outputMatrix);

command = 'convert_xfm -omat %s -inverse %s';
sentence = sprintf(command, fullOutputMatrix, fullInputMatrix);
[status, result] = CallSystem(sentence, config.verbose);

end
