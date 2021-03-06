function [status, result] = Erode(pathToWorkspace, config)
%ERODE Erode a volume one or more times.
%   Uses `fslmaths` to erode a volume.
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
  % filename for input
  config.inputVolume char
  % filename for output
  config.outputVolume char
  % type of erosion
  config.type char {mustBeMember(config.type, { ...
    'ero', ...  % zero non-zero voxels when zero voxels found in kernel
    'eroF' ...  % minimum filtering of all voxels
  })} = 'ero'
  config.numErosions int8 = 1
  config.verbose logical = false
  config.v logical = false
end

% assume all went well
success = true;

fullInputVolume = fullfile(pathToWorkspace, config.inputVolume);
fullOutputVolume = fullfile(pathToWorkspace, config.outputVolume);
results = cell(1, config.numErosions);
verbose = config.verbose || config.v;

% main command
command = 'fslmaths %s -%s %s';

% generate random temporary names
ext = '.nii.gz';
tmpIn = strcat([tempname ext]);
tmpOut = strcat([tempname ext]);
if verbose
  fprintf('generating temporary input filename %s\n', tmpIn);
  fprintf('generating temporary output filename %s\n', tmpOut);
end

cleanupTmpIn = onCleanup(@() cleanupFile(tmpIn, verbose));
cleanupTmpOut = onCleanup(@() cleanupFile(tmpOut, verbose));

% todo: update cleanup for all files
                
% copy the original filename to the temporary location
if verbose
  fprintf('copying input file %s to temporary input file %s\n', ...
          fullInputVolume, ...
          tmpIn);
end
status = copyfile(fullInputVolume, tmpIn);

% status ~= 1 indicates something went wrong
if (status ~= 1)
  if verbose
    fprintf('Erode: copy failed\n');
  end
  success = false;
  % todo: throw error
end

for i = 1 : config.numErosions
  if verbose
    fprintf('performing erosion #%d\n', i);
  end
  
  % prepare sentence for this loop
  sentence = sprintf(command, ...
                     tmpIn, ...
                     config.type, ...
                     tmpOut);

  [status, result] = CallSystem(sentence, verbose);
  
  % store result in results array
  results{i} = result;

  % status ~= 0 indicates something went wrong
  if (status ~= 0)
    if verbose
    	fprintf('erosion failed\n');
    end
    success = false;
    % not found calls to delete just give warnings
    if verbose
      fprintf('deleting temporary input file %s\n', tmpIn);
    end
    delete(tmpIn);
    if verbose
      fprintf('deleting temporary output file %s\n', tmpOut);
    end
    delete(tmpOut);
    % todo: throw error
    break;
  end
  % delete the temporary input file and for the next iteration, use the 
  % output as input and generate a new temporary output filename
  if verbose
    fprintf('deleting temporary input file %s\n', tmpIn);
  end
  delete(tmpIn);
 
  % reset vars for next loop iteration if performing multiple dilations
  if (i ~= config.numErosions)
    if verbose
      fprintf('reasigning previous temporary output file as temporary input file %s\n', tmpIn);
    end
    tmpIn = tmpOut;
    if verbose
      fprintf('creating new temporary output file %s\n', tmpOut);
    end
    tmpOut = strcat([tempname ext]);
  end
end

% copy the temp output to the desired output
if verbose
  fprintf('copying temporary output file %s to output file %s\n', ...
          tmpOut, ...
          fullOutputVolume);
end
status = copyfile(tmpOut, fullOutputVolume);
% status ~= 1 indicates something went wrong
if (status ~= 1)
  if verbose
    fprintf('copy failed\n');
  end
  success = false;
  % todo: throw error
end
% delete temp files
if verbose
  fprintf('deleting temporary output file %s\n', tmpOut);
end
delete(tmpOut)

if verbose
  if success
    fprintf('erosion succeeded\n');
  else
    fprintf('erosion failed\n');
  end
end

% a status of 0 signals everything went fine
result = results;
status = 0;

end

function cleanupFile(pathToFile, verbose)
  if exist(pathToFile, 'file')
    if verbose
      fprintf('deleting temporary file %s\n', pathToFile);
    end
    delete(pathToFile)
  end
end
