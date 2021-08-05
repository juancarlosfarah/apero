function [pipeline] = BuildRegisterToStandardPipeline(pathToWorkspace, ...
                                                      pathToDataset, ...
                                                      pathToParcellations, ...
                                                      pathToIntermediaryOutputs, ...
                                                      pathToOutput, ...
                                                      numSubjects, ...
                                                      config)
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

arguments
  pathToWorkspace char = '.'
  pathToDataset char = '.'
  pathToParcellations char = '.'
  pathToIntermediaryOutputs char = '.'
  pathToOutput char = '.'
  numSubjects int8 {mustBeNonnegative} = 0
  config = {}
end

% names of inputs needed to start the sequence
inputs = { ...
  fullfile(pathToDataset, '%s/anat/%s_T1w.nii.gz'), ...
  fullfile(pathToIntermediaryOutputs, '%s/%s_T1w_brain_mul.nii.gz'), ...
  fullfile(pathToParcellations, 'ch2bet.nii.gz'), ...
  fullfile(pathToParcellations, 'ch2.nii.gz') ...
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

sequences = cell(1, numSubjects);

% create a sequence for each subject
for i = 1 : numSubjects
  % get data for one participant
  subject = subjects(i, :);

  % participant_id is the column name and it's a cell
  subjectName = subject.participant_id{1};

  % create an input array for each sequence
  subjectInputs = cell(1, numInputs);
  for j = 1 : numInputs
    input = inputs{j};
    % get number of times subject name is needed
    subjectNameOccurences = count(input, '%s');
    [subjectNameArray{1:subjectNameOccurences}] = deal(subjectName);
    subjectInputs{j} = sprintf(input, subjectNameArray{:});
  end

  pathToSubjectWorkspace = fullfile(pathToWorkspace, subjectName);
  pathToSubjectOutput = fullfile(pathToOutput, subjectName);
  sequences{i} = BuildRegisterToStandardSequence(subjectInputs, ...
                                                 subjectName, ...
                                                 pathToSubjectWorkspace, ...
                                                 pathToSubjectOutput, ...
                                                 config);
end

% create a pipeline with the sequences
parallel = false;
pipeline = Pipeline(sequences, parallel);

end
