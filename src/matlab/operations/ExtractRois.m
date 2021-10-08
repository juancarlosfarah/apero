function [status, result] = ExtractRois(pathToWorkspace, config)
%EXTRACTROIS Summary of this function goes here
%   Detailed explanation goes here%   Detailed explanation goes here
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
  config.brainVolume char
  config.parcellationVolume char
  config.referenceVolume char
  config.outputFile char
  config.maskVolumes cell = {}
  % switch on diagnostic messages
  config.verbose logical = false
end

% succeed by default
status = 0;

% read files and get metadata
brainVolume = MRIread(fullfile(pathToWorkspace, config.brainVolume));
referenceVolume = MRIread(fullfile(pathToWorkspace, config.referenceVolume));
parc = MRIread(fullfile(pathToWorkspace, config.parcellationVolume));

[sizeX, sizeY, sizeZ, numTimePoints] = size(brainVolume.vol);


% do not consider voxels in these masks
for i = 1 : length(config.maskVolumes)
  maskVolume = config.maskVolumes{i};
  mask = MRIread(fullfile(pathToWorkspace, maskVolume));
  parc.vol = parc.vol .* (~mask.vol);
end

% only consider nonzero voxels in reference volume
parc = parc.vol .* (referenceVolume.vol > 0);

% track number of voxels in roi
numRois = max(parc(:));
numVoxels = nan(numRois, 1);
for roiIdx = 1 : numRois
  numVoxels(roiIdx, 1) = nnz(parc == roiIdx);
end

% calculate mean of voxels in each roi across time points
rois = zeros(numRois, numTimePoints);
for timePoint = 1 : numTimePoints
  aux = reshape(brainVolume.vol(:, :, :, timePoint), ...
                [sizeX, sizeY, sizeZ]);
  for roi = 1 : numRois
    voxelsRoi = (parc == roi);
    rois(roi, timePoint) = mean(aux(voxelsRoi));
  end

  % displays progress
  if mod(timePoint, 50) == 0
    fprintf('%d out of %d\n', timePoint, numTimePoints);
  end
end

% save resulting variables to file
save(fullfile(pathToWorkspace, config.outputFile), 'rois', 'numVoxels');

result = 'ExtractRois: saved result of extraction';
if config.verbose
  fprintf('%s\n', result);
end

end

