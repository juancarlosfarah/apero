function [status, result] = FillBrainMask(pathToWorkspace, config)
%FILLBRAINMASK Fill holes in a brain volume based on a reference volume.
%   Uses `fslmaths` with `fillh` to fill holes in a volume.
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
  config.inputVolume char
  config.referenceVolume char
  config.outputVolume char
  config.verbose logical = false
end

verbose = config.verbose;

fullInputVolume = fullfile(pathToWorkspace, config.inputVolume);
fullReferenceVolume = fullfile(pathToWorkspace, config.referenceVolume);
fullOutputVolume = fullfile(pathToWorkspace, config.outputVolume);

% read brain mask
volBrain = MRIread(fullInputVolume);
volRef = MRIread(fullReferenceVolume);

% ignore empty voxels
volBrain.vol = (volBrain.vol > 0) & (volRef.vol > 0);

% generate random temporary names
ext = '.nii.gz';
tmpFile = strcat([tempname ext]);
if verbose
  fprintf('generating temporary output filename %s\n', tmpFile);
end

cleanupTmpFile = onCleanup(@() cleanupFile(tmpFile, verbose));

% write filled brain mask
err = MRIwrite(volBrain, tmpFile, 'double');

if err
  % todo: throw error
  status = 1;
  result = 'FillBrainMask: error writing filled brain mask';
  fprintf('%s\n', result);
  return
end

% output from previous step is input to next step
command = 'fslmaths %s -fillh %s';
sentence = sprintf(command, tmpFile, fullOutputVolume);

[status, result] = CallSystem(sentence, config.verbose);

end

function cleanupFile(pathToFile, verbose)
  if exist(pathToFile, 'file')
    if verbose
      fprintf('deleting temporary file %s\n', pathToFile);
    end
    delete(pathToFile)
  end
end
