function [status, result] = DenoiseImage(pathToWorkspace, config)
% DENOISEIMAGE Denoises the volume inside an NIfTI image.
%
%   Input:
%   - pathToWorkspace:  Path to the workspace.
%   - config:           Configuration to be used in the operation.
%
%   Output:
%   - status:  Status returned.
%   - result:  Result returned.

arguments
  % has to be char due to issue with single vs double quotes
  % see more: github.com/juancarlosfarah/apero/issues/1
  pathToWorkspace char = '.'
  config.inputFile char
  config.outputFile char
  config.beta double = 1
  config.patchRadius int8 = 1
  config.searchRadius int8 = 1
  config.rician logical = false
  config.verbose logical = false
end

inputFile = config.inputFile;
outputFile = config.outputFile;

% todo: capture failure
image = MRIread(fullfile(pathToWorkspace, inputFile));
denoisedVol = Denoise(image.vol, ...
                      config.beta, ...
                      config.patchRadius, ...
                      config.searchRadius, ...
                      config.rician, ...
                      config.verbose);

image.vol = denoisedVol;
% output the denoised image
MRIwrite(image, fullfile(pathToWorkspace, outputFile));

% a status of 0 signals everything went fine
result = outputFile;
status = 0;

return
