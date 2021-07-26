classdef Step
  %STEP Summary of this class goes here
  %   Detailed explanation goes here

  properties
    Operation
    Parameters
    Dependencies
    Configuration
  end

  methods
    function obj = Step(op, params, deps, config)
      %STEP Construct an instance of this class
      %   Detailed explanation goes here
      obj.Operation = op;
      obj.Parameters = params;
      obj.Dependencies = deps;
      obj.Configuration = config;
    end

    function isValid = validateDependencies(obj, pathToWorkspace)
      %ISVALID Summary of this method goes here
      %   Detailed explanation goes here

      % if dependencies are not found in the workspace, abort
      for i = 1 : length(obj.Dependencies)
        dependency = obj.Dependencies{i};
        if ~exist(fullfile(pathToWorkspace, dependency), 'file')
          fprintf('step error:\n');
          fprintf('missing dependency %s\n', dependency);
          isValid = false;
          return
        end
      end
      isValid = true;
    end

    function [status, output] = run(obj, pathToWorkspace)
      %RUN Summary of this method goes here
      %   Detailed explanation goes here
      isValid = obj.validateDependencies(pathToWorkspace);
      if ~isValid
        status = false;
        return
      end
      % need to convert struct to name-value paired arguments
      params = namedargs2cell(obj.Parameters);
      config = namedargs2cell(obj.Configuration);
      % status = 0 signals everything went fine
      % if operation fails, returns a nonzero value in
      % status and an explanatory message in result
      [status, output] = obj.Operation(pathToWorkspace, ...
                                       params{:}, ...
                                       config{:});
    end
  end
end

