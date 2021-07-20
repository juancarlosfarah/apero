function [pipeline] = BuildSamplePipeline(pathToWorkspace, ...
                                          pathToDataset, ...
                                          pathToOutput)
%BUILDSAMPLEPIPELINE Example of a pipeline builder.
%   This builder creates a pipeline with one sequence per subject, based
%   on the format of a BIDS dataset's participants.tsv file.
%   
%   Input:
%   - pathToWorkspace:  Path to the workspace.
%   - pathToDataset:    Path to input the root of the BIDS dataset.
%   - pathToOutput:     Path to where we will output the data.
%
%   Output:
%   - pipeline:  Built pipeline.

% names of inputs needed to start the sequence
inputs = { 'T1w.nii.gz' };
numInputs = length(inputs);

% get information about participants
subjects = readtable(fullfile(pathToDataset, 'participants.tsv'), ...
                     'Delimiter', ...
                     '\t', ...
                     'FileType', ...
                     'delimitedtext', ...
                     'PreserveVariableNames', ...
                     true);
numSubjects = height(subjects);
sequences = cell(1, numSubjects);

% create a sequence for each subject
for i = 1 : numSubjects
  % get data for one participant
  subject = subjects(i, :);

  % participant_id is the column name and it's a cell
  subjectName = subject.participant_id{1};
  subjectPath = fullfile(pathToDataset, subjectName);

  % create an input array for each sequence
  subjectInputs = cell(1, numInputs);
  for j = 1 : numInputs
    input = inputs{j};
    subjectInputs{j} = fullfile(subjectPath, input);
  end

  pathToSubjectWorkspace = fullfile(pathToWorkspace, subjectName);
  pathToSubjectOutput = fullfile(pathToOutput, subjectName);
  sequences{i} = BuildSampleSequence(subjectInputs, ...
                                     pathToSubjectWorkspace, ...
                                     pathToSubjectOutput);
end

% create a pipeline with the sequences
pipeline = Pipeline(sequences, true);

end

