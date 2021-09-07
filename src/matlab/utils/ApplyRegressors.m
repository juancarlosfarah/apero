function resid = ApplyRegressors(data, mask, regressors, scrubbing)
%APPLYREGRESSORS Summary of this function goes here
%   Detailed explanation goes here

if nargin < 4
    scrubbing = true(size(data, 4), 1);
end

% remove identical regressors if present
regressors = unique(regressors', 'rows')';

[sizeX, sizeY, sizeZ, numTimePoints] = size(data);
resid = zeros(sizeX, sizeY, sizeZ, numTimePoints);

for i = 1 : sizeX
  for j = 1 : sizeY
    for k = 1 :  sizeZ
      if mask(i, j, k)
        tsVoxel = reshape(data(i, j, k, :), [numTimePoints, 1]);
        % coeffs learned from good points only
        b = regress(tsVoxel(scrubbing), regressors(scrubbing, :));
        b = repmat(b, 1, numTimePoints);
        yHat = sum(b .* regressors');
        resid(i, j, k, :) = tsVoxel - yHat';
      end
    end
  end
  % print progress
  if (mod(i, 25) == 0)
    fprintf('%d%% done applying regressors...\n', round(i / sizeX * 100));
  end
end
