function [status, result] = PerformRegression(pathToWorkspace, config)
%PERFORMREGRESSION Summary of this function goes here
%   Detailed explanation goes here
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
  config.maskVolume char
  config.outputVolume char
  % only regress if less than a threshold of outliers
  config.threshold double {mustBeInRange(config.threshold, 0, 1)} = 1
  config.outlierFiles cell = {}
  config.regressorFiles cell = {}
  config.regressorsOutputFile char
  config.outliersOutputFile char
  % switch on diagnostic messages
  config.verbose logical = false
end

% succeed by default
status = 0;

outlierFiles = config.outlierFiles;
regressorFiles = config.regressorFiles;
brainVolume = MRIread(fullfile(pathToWorkspace, config.brainVolume));
maskVolume = MRIread(fullfile(pathToWorkspace, config.maskVolume));

% count number of time points
[~, ~, ~, numTimePoints] = size(brainVolume.vol);

[mask, ~] = Generate4dMask(fullfile(pathToWorkspace, config.maskVolume), ...
                           numTimePoints);

% set voxels outside the brain to 0
brainVolume.vol(~mask) = 0;
  
%% outlier indexes
% we can still have volumes that are affected by motion
% here we track them and visualize them
% we transform outliers to non-outliers, where 1 indicates volume is 
% not an outlier and 0 that it should be considered for omission

% we start with everything
nonOutliers = true(numTimePoints, 1);

% remove outliers from all the specified files
for i = 1 : length(outlierFiles)
  outlierFile = outlierFiles{i};
  fileOutliers = load(fullfile(pathToWorkspace, outlierFile)).outliers;
  nonOutliers = nonOutliers & ~fileOutliers;
end

% outliers are the opposite of nonOutliers (saved in file later)
outliers = ~nonOutliers;

% only regress if less than a threshold of outliers
if (nnz(outliers) / length(outliers)) < config.threshold

  % prepare regressors
  regressors = [];
  for i = 1 : length(regressorFiles)
    regressorFile = regressorFiles{i};
    regressorFileObj = matfile(fullfile(pathToWorkspace, regressorFile));
    regVars = who(regressorFileObj);
    for r = 1 : length(regVars)
      regVar = regVars{r};
      regressor = regressorFileObj.(regVar);
      % suppress warning of growing array
      regressors{end + 1} = regressor; %#ok<AGROW>
    end
  end
  
  % merge regressors
  regressors = cat(2, regressors{:});

  regressorsNormalized = nan(size(regressors));

  for i = 1 : size(regressors, 2)
    regVar = regressors(:, i);
    % calculate mean on good points
    regMean = mean(regVar(nonOutliers));
    % calculate std on good points
    regStd = std(regVar(nonOutliers));
    % zscore all
    zreg = (regVar - regMean) ./ regStd;
    % calculate linear trend on good points
    vec = 1 : 1 : nnz(nonOutliers);
    coeffs = polyfit(vec', zreg(nonOutliers), 1);
    % detrend all
    regressorsNormalized(:, i) = zreg - ((coeffs(1) * (1 : length(nonOutliers))) + coeffs(2))';
  end

  % what does this do?
  % start at the end of the vector to match the dimensions of the ts
  regressors(:, end + 1) = 1;
  regressorsNormalized(:, end + 1) = 1;

  % save regressors
  regressorsOutputFile = fullfile(pathToWorkspace, config.regressorsOutputFile);
  save(regressorsOutputFile, 'regressors', 'regressorsNormalized');

  %% regress out normalized regressors
  brainVolume.vol = ApplyRegressors(brainVolume.vol, ...
                                    maskVolume.vol, ...
                                    regressorsNormalized, ...
                                    nonOutliers);

  outputVolume = fullfile(pathToWorkspace, config.outputVolume);
  % write brain volume with regressors applied
  err = MRIwrite(brainVolume, outputVolume, 'double');

  if err
    % todo: throw error
    status = 1;
    result = 'PerformRegression: error writing brain volume';
    fprintf('%s\n', result);
    return
  end

else
  % signal too many outliers
  fprintf('file %s contains more outliers (%0.2f) than the threshold (%0.2f)\n', ...
          inputPath, ...
          nnz(outliers) / length(outliers), ...
          config.threshold)
  
  % save non-outliers as regressors as well as outliers
  regressorsOutputFile = fullfile(pathToWorkspace, config.regressorsOutputFile);
  fprintf('skipping regression, saving non-outliers as regressors in %s', ...
          regressorsOutputFile);
  save(fullfile(pathToWorkspace, regressorsOutputFile), 'nonOutliers');
  
end

result = 'PerformRegression: saved result of regression';
if config.verbose
  fprintf('%s\n', result);
end

% in both cases, save outliers file
save(fullfile(pathToWorkspace, config.outliersOutputFile), 'outliers');

end

