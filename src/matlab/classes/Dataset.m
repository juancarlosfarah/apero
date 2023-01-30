classdef Dataset
  %DATASET Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Path
  end
  
  methods
    function obj = Data(inputArg1,inputArg2)
      %DATA Construct an instance of this class
      %   Detailed explanation goes here
      obj.Property1 = inputArg1 + inputArg2;
    end
    
    function outputArg = method1(obj,inputArg)
      %METHOD1 Summary of this method goes here
      %   Detailed explanation goes here
      outputArg = obj.Property1 + inputArg;
    end
    
    % setters
    function obj = set.Path(obj, p)
      obj.Path = p;
    end

  end
end
