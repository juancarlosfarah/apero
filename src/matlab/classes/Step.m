classdef Step
  %STEP Summary of this class goes here
  %   Detailed explanation goes here

  properties
    Operation
    Parameters = {}
    Dependencies = {}
    Configuration = {}
    Outputs = {}
  end

  methods
    function obj = Step(op, params, deps, config, outputs)
      %STEP Construct an instance of this class
      %   Detailed explanation goes here
      arguments
        op
        params = {}
        deps = {}
        config = {}
        outputs = {}
      end

      obj.Operation = op;
      obj.Parameters = params;
      obj.Dependencies = deps;
      obj.Configuration = config;
      obj.Outputs = outputs;
    end

    function [isValid, err] = validateDependencies(obj, pathToWorkspace)
      %ISVALID Summary of this method goes here
      %   Detailed explanation goes here

      % if dependencies are not found in the workspace, abort
      for i = 1 : length(obj.Dependencies)
        dependency = obj.Dependencies{i};
        if ~exist(fullfile(pathToWorkspace, dependency), 'file')
          fprintf('step error:\n');
          err = sprintf('missing dependency %s', dependency);
          fprintf('%s\n', err);
          isValid = false;
          return
        end
      end
      isValid = true;
      err = false;
    end

    function [passed, err] = performNoClobberCheck(obj, pathToWorkspace)
      % if outputs are not found in the workspace, abort
      for i = 1 : length(obj.Outputs)
        output = obj.Outputs{i};
        if exist(fullfile(pathToWorkspace, output), 'file')
          err = sprintf('output %s exists in workspace', output);
          solution = 'step must be run with the `clobber` option';
          warning('%s\n%s', err, solution);
          passed = false;
          return
        end
      end
      passed = true;
      err = false;
    end

    function [status, output] = run(obj, pathToWorkspace)
      %RUN Summary of this method goes here
      %   Detailed explanation goes here
      [isValid, error] = obj.validateDependencies(pathToWorkspace);
      if ~isValid
        % status = 1 signals an error
        status = 1;
        output = error;
        return
      end

      % check if we need to clobber any outputs
      clobber = isfield(obj.Configuration, 'clobber') && ...
                obj.Configuration.clobber == true;
      
      % if the clobber flag is not set, then we need to check for the
      % presence of outputs that may be clobbered if we run
      if ~clobber
        [passed, error] = obj.performNoClobberCheck(pathToWorkspace);
        if ~passed
          % status = 1 signals an error
          status = 1;
          output = error;
          return
        end
      else
        opName = 'Anonymous';
        try
          opName = functions(obj.Operation).function;
        catch
          warning('caught error using `functions` to get operation name');
        end
        warning('running %s step with clobber option', opName);
      end

      % check if we are clobbering outputs
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

