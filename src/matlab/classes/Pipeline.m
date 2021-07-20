classdef Pipeline
  %PIPELINE Summary of this class goes here
  %   Detailed explanation goes here

  properties
    Sequences
    Outputs
    Parallel
  end
    
  methods
    function obj = Pipeline(sequences, ...
                            parallel)
      %PIPELINE Construct an instance of this class
      %   Detailed explanation goes here
      obj.Sequences = sequences;
      obj.Outputs = cell(1, length(sequences));
      obj.Parallel = parallel;
    end

    function [success, outputs] = run(obj)
      %RUN Summary of this method goes here
      %   Detailed explanation goes here
      numSequences = length(obj.Sequences);
      sequences = obj.Sequences;
      outputs = obj.Outputs;
      
      % parallel or sequential processing
      if obj.Parallel
        parfor i = 1 : numSequences
          sequence = sequences{i};
          outputs{i} = sequence.run();
        end
      else
        for i = 1 : numSequences
          sequence = obj.Sequences{i};
          outputs{i} = sequence.run();
        end
      end

      % copy outputs back to object
      for i = 1 : numSequences
        obj.Outputs{i} = outputs{i};
      end
    end
  end
end

