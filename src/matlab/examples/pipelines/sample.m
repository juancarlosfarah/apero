
dataset = Dataset();

sequence = Sequence();

% add all sequences to create a pipeline
% each combination of sequence + dataset should be run as a "sequence block"
pipeline = Pipeline();

pipeline.save();

pipeline.run();

