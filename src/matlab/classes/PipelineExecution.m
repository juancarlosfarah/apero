classdef PipelineExecution
  %PIPELINEEXECUTION Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    StartTime datetime
    EndTime datetime
    Error string
    Duration double
    Success logical
    Result
  end
  
  methods
    function obj = PipelineExecution()
      %PIPELINEEXECUTION Construct an instance of this class
      %   Detailed explanation goes here
    end
    
    % setters
    function obj = set.StartTime(obj, startTime)
      obj.StartTime = startTime;
    end

    function obj = set.EndTime(obj, endTime)
      obj.EndTime = endTime;
    end

    function obj = set.Success(obj, success)
      obj.Success = success;
    end
    
    function obj = set.Result(obj, result)
      obj.Result = result;
    end
    
    function obj = set.Duration(obj, duration)
      obj.Duration = duration;
    end
    
    function obj = set.Error(obj, error)
      obj.Error = error;
    end
  end
end

