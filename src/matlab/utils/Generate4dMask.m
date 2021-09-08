function [mask, numVoxels] = Generate4dMask(volume, numTimePoints)
%GENERATE4DMASK Summary of this function goes here
%   Generates a 4D mask from a 3D volume.

mask = MRIread(volume);
numVoxels = nnz(mask.vol);

mask = logical(repmat(mask.vol, [1, 1, 1, numTimePoints]));

end

