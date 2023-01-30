function [pipeline] = BuildFunctionalConnectivityPipeline(pathToWorkspace, ...
                                                          pathToDataset, ...
                                                          pathToIntermediaryOutputs, ...
                                                          pathToOutput, ...
                                                          numSubjects, ...
                                                          config)
%BUILDFUNCTIONALCONNECTIVITYPIPELINE Example of a pipeline builder.
%   This builder creates a pipeline with one sequence per run per subject, based
%   on the format of a BIDS dataset's participants.tsv file.
%
%   Input:
%   - pathToWorkspace:  Path to the workspace.
%   - pathToDataset:    Path to input the root of the BIDS dataset.
%   - pathToOutput:     Path to where we will output the data.
%
%   Output:
%   - pipeline:  Built pipeline.

arguments
  pathToWorkspace char = '.'
  pathToDataset char = '.'
  pathToIntermediaryOutputs char = '.'
  pathToOutput char = '.'
  numSubjects int8 {mustBeNonnegative} = 0
  config = struct()
end

% names of inputs needed to start the sequence
inputs = { ...
  fullfile(pathToIntermediaryOutputs, ...
           '{subject}/{subject}_T1w_brain_trim.nii.gz'), ...
  fullfile(pathToIntermediaryOutputs, ...
           '{subject}/T1w_csf_mask.nii.gz'), ...
  fullfile(pathToIntermediaryOutputs, ...
           '{subject}/T1w_gm_mask.nii.gz'), ...
  fullfile(pathToIntermediaryOutputs, ...
           '{subject}/T1w_wm_mask.nii.gz'), ...
  fullfile(pathToIntermediaryOutputs, ...
           '{subject}/T1w_wm_mask_ero.nii.gz'), ...
  fullfile(pathToIntermediaryOutputs, ...
           '{subject}/T1w_csf_mask_ero.nii.gz'), ...
  fullfile(pathToIntermediaryOutputs, ...
           '{subject}/T1w_csfvent_mask_ero.nii.gz'), ...
  fullfile(pathToIntermediaryOutputs, ...
           '{subject}/{subject}_T1w_brain_mask_filled.nii.gz'), ...
  fullfile(pathToIntermediaryOutputs, ...
           '{subject}/{subject}_T1w_gm_parc.nii.gz'), ...
  fullfile(pathToDataset, ...
           '{subject}/func/{subject}_task-convers_{run}_bold.nii.gz'), ...
};
numInputs = length(inputs);

% get information about participants
subjects = readtable(fullfile(pathToDataset, 'participants.tsv'), ...
                     'Delimiter', ...
                     '\t', ...
                     'FileType', ...
                     'delimitedtext', ...
                     'PreserveVariableNames', ...
                     true);

tableHeight = height(subjects);
if ~numSubjects
  numSubjects = tableHeight;
else
  numSubjects = min(numSubjects, tableHeight);
end

% there are four runs per subject
runs = { 'run-01' }; %, 'run-02', 'run-03', 'run-04' };
numRuns = length(runs);
sequences = cell(1, numSubjects * numRuns);

% create a sequence for each subject
for i = 1 : numSubjects
  % get data for one participant
  subject = subjects(i, :);

  % participant_id is the column name and it's a cell
  subjectName = subject.participant_id{1};

  % create an input array for each subject
  subjectInputs = cell(1, numInputs);
  for j = 1 : numInputs
    input = inputs{j};

    % replace subject name
    subjectInputs{j} = strrep(input, '{subject}', subjectName);
  end

  % now prepare a sequence for each of the subject's runs
  for k = 1 : numRuns
    run = runs{k};

    % sequence index
    sequenceIdx = (i - 1) * numRuns + k;

    % create an input array for each run sequence
    runInputs = cell(1, numInputs);
    for l = 1 : numInputs
      subjectInput = subjectInputs{l};

      % replace run name
      runInputs{l} = strrep(subjectInput, '{run}', run);
    end

    pathToRunWorkspace = fullfile(pathToWorkspace, subjectName, run);
    pathToRunOutput = fullfile(pathToOutput, subjectName, run);

    % add to sequences at the right index
    sequences{sequenceIdx} = BuildFunctionalConnectivitySequence(runInputs, ...
                                                                 subjectName, ...
                                                                 run, ...
                                                                 pathToRunWorkspace, ...
                                                                 pathToRunOutput, ...
                                                                 config);

  end
end

% create a pipeline with the sequences
parallel = config.parallel;
pipeline = Pipeline(sequences, parallel);

end
