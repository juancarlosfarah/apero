function [status, result] = DetectStdDevOutliers(pathToWorkspace, ...
                                                 config)
%DETECTSTDDEVOUTLIERS Detect standard deviation outliers.
%   Uses `fslstats` to detect standard deviation outliers.
%
%   Input:
%   - pathToWorkspace:  Path to the workspace.
%   - config:           Configuration to be used in the operation.
%
%   Output:
%   - status:  Status returned by system call.
%   - result:  Result returned by system call.
%  

arguments
  pathToWorkspace char = '.'
  % filename for input
  config.inputVolume char
  % path for output
  config.outputFile char
  % path for outliers
  config.outputOutliers char = 'stdDevOutliers.mat'
  % specify absolute threshold value 
  config.thresh double {mustBeInRange(config.thresh, 0, 1)}
  config.verbose logical = false
end

inputVolume = fullfile(pathToWorkspace, config.inputVolume);
outputFile = fullfile(pathToWorkspace, config.outputFile);
outliersFile = fullfile(pathToWorkspace, config.outputOutliers);
verbose = config.verbose;

%% get standard deviations

% preoption -t will give a separate output line for each 3D volume of a 4D timeseries
% option -S will output standard deviation (for nonzero voxels)
command = 'fslstats -t %s -S';
command = sprintf(command, inputVolume);

% output to file
command = sprintf('%s > %s', command, outputFile);

[status, result] = CallSystem(command, verbose);

%% detect outliers
stdDevs = load(outputFile);
% use default in case config.thresh is not defined
if isfield(config, 'thresh')
  threshold = config.thresh;
else
  if verbose
    disp('defaulting to box-plot cutoff = p75 + 1.5 * iqr threshold');
  end
  % this follows default fsl criterion for outliers
  threshold = prctile(stdDevs, 75) + (1.5 * iqr(stdDevs));
end

outliers = stdDevs > threshold;
% save outliers in file for future use
save(outliersFile, 'outliers');
  
% report if verbose
if verbose
  fprintf('identified %d outliers for standard deviation regression\n', nnz(outliers));
end


end

