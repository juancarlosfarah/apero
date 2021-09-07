function [mask, numVoxels] = GetMask(volume, numTimePoints)
%GETMASK Summary of this function goes here
%   Detailed explanation goes here

mask = MRIread(volume);
numVoxels = nnz(mask.vol);

mask = logical(repmat(mask.vol, [1, 1, 1, numTimePoints]));

end

