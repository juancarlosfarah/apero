classdef Pipeline
  %PIPELINE Summary of this class goes here
  %   Detailed explanation goes here

  properties
    Sequences
    Parallel
  end
    
  methods
    function obj = Pipeline(sequences, ...
                            parallel)
      %PIPELINE Construct an instance of this class
      %   Detailed explanation goes here
      obj.Sequences = sequences;
      obj.Parallel = parallel;
    end

    function [pipelineExecution] = run(obj)
      %RUN Summary of this method goes here
      %   Detailed explanation goes here
      numSequences = length(obj.Sequences);
      sequences = obj.Sequences;
      results = cell(1, numSequences);
      
      % create a pipeline execution to track results
      pipelineExecution = PipelineExecution();

      % start execution
      timeStart = tic;
      pipelineExecution.StartTime = datetime;
      
      % by default succeed
      pipelineExecution.Success = true;
      
      % parallel or sequential processing
      if obj.Parallel
        parfor i = 1 : numSequences
          sequence = sequences{i};
          [sequenceExecution] = sequence.run();
          results{i} = sequenceExecution;
        end
      else
        for i = 1 : numSequences
          sequence = obj.Sequences{i};
          [sequenceExecution] = sequence.run();
          results{i} = sequenceExecution;
        end
      end

      % check if everything succeeded
      % has to be done here due to parfor
      % loop option
      for i = 1 : numSequences
          sequenceExecution = results{i};
          % todo: have optional sequences and handle errors
          if ~sequenceExecution.Success
            pipelineExecution.Success = false;
          end
      end

      pipelineExecution.Result = results;
      pipelineExecution.Duration = toc(timeStart);
      pipelineExecution.EndTime = datetime;
    end
  end
end

