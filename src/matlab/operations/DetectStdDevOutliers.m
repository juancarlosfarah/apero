function [status, result] = DetectStdDevOutliers(pathToWorkspace, ...
                                                 params, ...
                                                 config)
%DETECTSTDDEVOUTLIERS Detect standard deviation outliers.
%   Uses `fslstats` to detect standard deviation outliers.
%
%   Input:
%   - pathToWorkspace:  Path to the workspace.
%   - params:           Parameters to be used in the operation.
%   - config:           Configuration to be used in the operation.
%
%   Output:
%   - status:  Status returned by system call.
%   - result:  Result returned by system call.
%  

arguments
  pathToWorkspace char = '.'
  % filename for input
  params.inputVolume char
  % path for output
  params.outputFile char
  % path for outliers
  params.outputOutliers char = 'stdDevOutliers.mat'
  % specify absolute threshold value 
  config.thresh double {mustBeInRange(config.thresh, 0, 1)}
  config.verbose logical = false
end

inputVolume = fullfile(pathToWorkspace, params.inputVolume);
outputFile = fullfile(pathToWorkspace, params.outputFile);
outliersFile = fullfile(pathToWorkspace, params.outputOutliers);
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

