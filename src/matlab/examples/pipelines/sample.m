% define paths with respect to this file
filePath = fileparts(which(mfilename));

% define source data / scopes
dataset = Dataset();
% { subject: { path: '.anat/sub-##' } , run: 'run' }
% { yeo7: './path/to/yeo', yeo15: '/path/to/another/yeo' }
% csv or iterable of list of each scope:
%   { anat: ['anat/sub-01', 'anat/sub-02' ...], run: [ 'run-01', 'run-02' ] }

% define transfer and output folders
% clean up
workspace = Workspace();

subjectScope = [???];

% option 1
% all the scopes' sequences are "captured" in sequence1
sequence1 = BrainExtractionTemplate(dataset, scopes);
%block = PrepareSequence(dataset, subjectScope, sequence1);

% option 2
% all the scopes' sequences are "captured" in sequence1
block = BuildBlock(@BrainExtractionTemplate, dataset, scopes);
%block = PrepareSequence(dataset, subjectScope, sequence1);

sequence1.run(3) % run third scope

sequence2 = TransformParcellationSequence();
cohort2 = PrepareSequence(dataset, subjectScope

% add all sequences to create a pipeline
% each combination of sequence + dataset should be run as a "sequence block"

% option 3
pipeline = Pipeline(...
  dataset, ...
  [ ...
    { @BrainExtractionTemplate,  scopes}, ...
    { @TransformParcellationSequence, scopes }, ...
  ] ...
);

pipeline.save();

