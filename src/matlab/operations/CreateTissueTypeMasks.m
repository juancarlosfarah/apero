function [status, result] = CreateTissueTypeMasks(pathToWorkspace, ...
                                                         params, ...
                                                         config)
%CREATETISSUETYPEMASKS Creates masks by tissue type from a volume.
%   Uses `fslmaths` to create masks from a volume following integer labels.
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
  % filename of input image (to be masked)
  params.inputVolume char
  config.tissueTypeLabels cell = { 'csf', 'wm', 'gm' }
  config.startTypeValue int8 {mustBePositive} = 1
  config.endTypeValue int8 {mustBePositive} = 3
  % switch on diagnostic messages
  config.verbose logical = false
  config.v logical = false
end

% normalize if multiple options mean the same thing
verbose = config.verbose || config.v;

% extract values from config for legibility
startTypeValue = config.startTypeValue;
endTypeValue = config.endTypeValue;
tissueTypeLabels = config.tissueTypeLabels;

% error if start type value is grater than end type value
if startTypeValue > endTypeValue
  error('start type value (%d) is greater than end type value (%d)', ...
        startTypeValue, ...
        endTypeValue);
end

% by default succeed
success = true;

% used to keep track of results
numValuesToConsider = endTypeValue - startTypeValue + 1;
results = cell(1, numValuesToConsider);

% full input
fullInputVolume = fullfile(pathToWorkspace, params.inputVolume);

% create each mask
for i = startTypeValue : endTypeValue
  fileOut = fullfile(pathToWorkspace, ...
                     sprintf('T1w_%s_mask.nii.gz', tissueTypeLabels{i}));
  command = 'fslmaths %s -thr %d -uthr %d -div %d %s';
  sentence = sprintf(command, ...
                     fullInputVolume, ...
                     i, ...
                     i, ...
                     i, ...
                     fileOut);
  [sentenceStatus, result] = CallSystem(sentence, verbose);
  if (sentenceStatus ~= 0)
    success = false;
    % todo: throw error
  end
  results{i} = result;
end

if success
  status = 0;
else
  status = 1;
end

end

