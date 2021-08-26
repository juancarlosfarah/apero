function [status, result] = ThresholdClusters(pathToWorkspace, ...
                                              params, ...
                                              config)
%THRESHOLDCLUSTERS Summary of this function goes here
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
  pathToWorkspace char = '.'
  % filename of input image
  params.inputVolume char
  % filename of output image
  params.outputVolume char
  % only keep regions that have voxels above the threshold
  config.threshold int8 = 0
  % switch on diagnostic messages
  config.verbose logical = false
  config.v logical = false
end

% extract properties from config
verbose = config.verbose || config.v;
threshold = config.threshold;

fullInputVolume = fullfile(pathToWorkspace, params.inputVolume);
fullOutputVolume = fullfile(pathToWorkspace, params.outputVolume);

v = MRIread(fullInputVolume);

% max of the volume should give you the number of regions
numRegions = max(v.vol(:));
thresholdedVolume = zeros(size(v.vol));

numThresholdedRegions = 0;

for i=1:numRegions
    % function to look for connected components
    clusters = bwconncomp(v.vol == i);
    regionHasCluster = false;
    for j=1:clusters.NumObjects
        % only keep regions that have voxels above the threshold
        if length(clusters.PixelIdxList{j}) > threshold
            thresholdedVolume(clusters.PixelIdxList{j}) = i;
            regionHasCluster = true;
        end
    end
    if ~regionHasCluster
      numThresholdedRegions = numThresholdedRegions + 1;
      if verbose
        fprintf('ignoring region %d\n', i);
      end
    end
end

v.vol = thresholdedVolume;

% write to outputfile
status = MRIwrite(v, fullOutputVolume);

msg = sprintf('ThresholdClusters: removed %d regions with fewer than %d voxels', ...
              numThresholdedRegions, ...
              threshold);
            
if verbose
  disp(msg);
end
result = msg;

end
