function [status, result] = DetectMotionOutliers(pathToWorkspace, config)
%DETECTMOTIONOUTLIERS Detect motion outliers.
%   Uses `fsl_motion_outliers` to detect motion outliers.
%
%   Input:
%   - pathToWorkspace:  Path to the workspace.
%   - config:           Configuration to be used in the operation.
%
%   Output:
%   - status:  Status returned by system call.
%   - result:  Result returned by system call.
%  
% todo: -t <path>            [Optional] Path to the location where temporary files should be created. Defaults to /tmp
%       --nomoco             do not run motion correction (assumed already done)
%       --dummy=<val>        number of dummy scans to delete (before running anything and creating EVs)

arguments
  pathToWorkspace char = '.'
  % filename for input
  config.inputVolume char
  % path for output
  config.outputPath char
  % use supplied mask image for calculating metric
  config.maskVolume char
  % type of metric
  config.metric char {mustBeMember(config.metric, { ...
    'refrms', ... % use RMS intensity difference to reference volume
    'refmse', ... % Mean Square Error version of --refrms
    'dvars', ...  % use DVARS as metric
    'fd', ...     % use FD (framewise displacement) as metric
    'fdrms', ...  % use FD with RMS matrix calculation as metric
  })} = 'refrms'
  % specify absolute threshold value 
  config.thresh double {mustBeInRange(config.thresh, 0, 1)}
  config.verbose logical = false
end

inputVolume = fullfile(pathToWorkspace, config.inputVolume);
outputPath = fullfile(pathToWorkspace, config.outputPath);
metric = config.metric;
verbose = config.verbose;

%% create output folder if it doesn't exist
if ~exist(outputPath, 'dir')
  [status, msg] = mkdir(outputPath);
  if (status ~= 1)
    % todo: throw error
    fprintf(msg);
  end
end

outputFile = fullfile(outputPath, sprintf('motionRegressor_%s.txt', metric));
metricsFile = fullfile(outputPath, sprintf('motionMetric_%s.txt', metric));
plotFile = fullfile(outputPath, sprintf('motionPlot_%s.png', metric));
outliersFile = fullfile(outputPath, sprintf('motionOutliers_%s.mat', metric));

% delete existing files just in case
if exist(outputFile, 'file')
  delete(outputFile);
end
if exist(metricsFile, 'file')
  delete(metricsFile);
end
if exist(plotFile, 'file')
  delete(plotFile);
end
if exist(outliersFile, 'file')
  delete(outliersFile);
end

% usage: fsl_motion_outliers -i <input 4D image> -o <output confound file> [options]
% options: -s <filename> save metric values (e.g. DVARS) as text into specified file
%          -p <filename> save metric values (e.g. DVARS) as a graphical plot (png format)
command = 'fsl_motion_outliers -i %s -o %s -s %s -p %s --%s';

command = sprintf(command, ...
                  inputVolume, ...
                  outputFile, ...
                  metricsFile, ...
                  plotFile, ...
                  metric);

% use supplied mask image for calculating metric
if isfield(config, 'maskVolume')
  maskVolume = fullfile(pathToWorkspace, config.maskVolume);
  command = sprintf('%s -m %s', command, maskVolume);
end

% specify absolute threshold value (otherwise use box-plot cutoff = P75 + 1.5*IQR)
if isfield(config, 'thresh')
  threshold = config.thresh;
  command = sprintf('%s --thresh=%0.4f', command, threshold);
else
  threshold = [];
  if verbose
    disp('defaulting to box-plot cutoff = p75 + 1.5 * iqr threshold');
  end
end

% verbose (switch on diagnostic messages)
if verbose
  command = sprintf('%s -v', command);
end

[status, result] = CallSystem(command, verbose);

% show position of outliers
if exist(metricsFile, 'file')
  metrics = load(metricsFile);
  % use default in case config.thresh is not defined
  if isempty(threshold)
    % this follows default fsl criterion for outliers
    threshold = prctile(metrics, 75) + (1.5 * iqr(metrics));
  end
  outliers = metrics > threshold;
  % save outliers in file for future use
  save(outliersFile, 'outliers');
  if verbose
    fprintf('identified %d outliers for %s regression\n', nnz(outliers), metric);
  end
else
  error('output file %s not found', metricsFile)
end

end

