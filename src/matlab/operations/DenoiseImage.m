function [status, result] = DenoiseImage(pathToWorkspace, ...
                                         params, ...
                                         config)
% DENOISEIMAGE Denoises the volume inside an NIfTI image.
%
%   Input:
%   - pathToWorkspace:  ...
%   - params:           ...
%   - config:           ...
%
%   Output:
%   - success:  ...
%   - result:   ...

arguments
  % has to be char due to issue with single vs double quotes
  % see more: github.com/juancarlosfarah/apero/issues/1
  pathToWorkspace char = '.'
  params.inputFile char
  params.outputFile char
  config.beta double = 1
  config.patchRadius int8 = 1
  config.searchRadius int8 = 1
  config.rician logical = false
  config.verbose logical = false
end

inputFile = params.inputFile;
outputFile = params.outputFile;

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
