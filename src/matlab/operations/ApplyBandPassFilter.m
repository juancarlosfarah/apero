function [status, result] = ApplyBandPassFilter(pathToWorkspace, ...
                                                params, ...
                                                config)
%APPLYBANDPASSFILTER Summary of this function goes here
%   Detailed explanation goes here
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
  params.inputVolume char
  params.outputVolume char
  params.timeSeriesFile char
  config.fMin double {mustBeInRange(config.fMin, 0, 1)}
  config.fMax double {mustBeInRange(config.fMax, 0, 1)}
  config.temporalResolution double
  config.order double {mustBeInteger} = 1
  % switch on diagnostic messages
  config.verbose logical = false
end

inputVolume = MRIread(fullfile(pathToWorkspace, params.inputVolume));
outputVolume = fullfile(pathToWorkspace, params.outputVolume);

load(fullfile(pathToWorkspace, params.timeSeriesFile), 'ts', 'mask');

% applies band pass filter to the given timeseries and mask
fMin = config.fMin;
fMax = config.fMax;
temporalResolution = config.temporalResolution;

% succeed by default
status = 0;

f1 = (fMin * 2) * temporalResolution;
f2 = (fMax * 2) * temporalResolution;

[tsf] = ApplyButterworthFilter(ts, config.order, f1, f2);

inputVolume.vol(mask) = tsf';

err = MRIwrite(inputVolume, outputVolume, 'double');

if err
  % todo: throw error
  status = 1;
  result = 'ApplyBandPassFilter: error writing volume';
  fprintf('%s\n', result);
  return
end

result = 'ApplyBandPassFilter: saved filtered output';
if config.verbose
  fprintf('%s\n', result);
end

end

