function [pcTop, variance, latent] = GetPca(ts, numComps)
%GETPCA Summary of this function goes here
%   Detailed explanation goes here
%   
%   Input:
%   - ts:       Time series.
%   - numComps: Number of components desired.
%
%   Output:
%   - pcTop:    Top numComps components.
%   - variance: Variance.
%   - latent:   Descending order in terms of component variance.

if numComps > 0
    [~, pc, latent] = pca(ts, 'Economy', 'on');
    
    % explained variance
    variance = cumsum(latent) ./ sum(latent);
    pcTop = pc(:, 1 : numComps);
    variance = variance(1 : numComps);
else
    pcTop = [];
    variance = [];
    latent = [];
end

end

