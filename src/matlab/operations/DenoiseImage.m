function [success, result] = DenoiseImage(pathToWorkspace, ...
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
  pathToWorkspace string = '.'
  params.inputFile string
  params.outputFile string
  config.beta double = 1
  config.patchRadius int8 = 1
  config.searchRadius int8 = 1
  config.rician boolean = false
  config.verbose boolean = false
end

% todo: capture failure
image = MRIread(fullfile(pathToWorkspace, inputFile));
denoisedVol = Denoise(image.vol, ...
                      beta, ...
                      patchRadius, ...
                      searchRadius, ...
                      rician, ...
                      verbose);

image.vol = denoisedVol;
% output the denoised image
MRIwrite(image, fullfile(pathToWorkspace, outputFile));

result = outputFile;
success = true;

return
