function [denoisedVol] = Denoise(volume, ...
                                 beta, ...
                                 patchRadius, ...
                                 searchRadius, ...
                                 rician, ...
                                 verbose)
% DENOISE Denoise a volume.
%
% Uses Pierrick Coupé's MRIDenoisingPackage
% https://bit.ly/3zdIX2w
%
%   Input:
%   - volume:        ...
%   - beta:
%   - patchRadius:
%   - searchRadius:
%   - rician:
%   - verbose:      Boolean indicating verbosity.
%
%   Output:
%   - denoisedVol:    ...

arguments
  volume
  beta double = 1
  patchRadius int8 = 1
  searchRadius int8 = 1
  rician boolean = false
  verbose boolean = false
end

%% normalize intensity range to [0, 256]
map = isnan(volume(:));
volume(map) = 0;
map = isinf(volume(:));
volume(map) = 0;
minIdx = min(volume(:));
volume = volume - minIdx;
maxIdx = max(volume(:));
volume = volume * 256 / maxIdx;

%% noise estimation
% outputs [hfinal, ho, SNRo, hbg, SNRbg]
[hfinal, ~, ~, ~, ~] = MRINoiseEstimation(volume, rician, verbose);

%% denoising
denoisedVol = MRIDenoisingONLM(volume, ...
                               hfinal, ...
                               beta, ...
                               patchRadius, ...
                               searchRadius, ...
                               rician, ...
                               verbose);
map = denoisedVol < 0;
denoisedVol(map) = 0;

%% restore original intensity range
denoisedVol = (denoisedVol * maxIdx) / 256;
denoisedVol = denoisedVol + minIdx;

return
