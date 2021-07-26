function [status, result] = FillMask(pathToWorkspace, ...
                                     params, ...
                                     config)
%FILLMASK Fill holes in the brain mask, without changing fov.
%   Uses `fslmaths` with `fillh` to fill holes in a mask.
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
  pathToWorkspace string = '.'
  params.inputFile string
  params.outputFile string
  config.verbose logical = false
end

fullInputFile = fullfile(pathToWorkspace, params.inputFile);
fullOutputFile = fullfile(pathToWorkspace, params.outputFile);
command = 'fslmaths %s -fillh %s';
sentence = sprintf(command, fullInputFile, fullOutputFile);
  
[status, result] = CallSystem(sentence, config.verbose);

end

