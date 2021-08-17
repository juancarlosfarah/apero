classdef Sequence
  %SEQUENCE Summary of this class goes here
  %   Detailed explanation goes here

  properties
    Steps
    Inputs
    Outputs
    WorkspacePath
    OutputPath
    Results
    Ready
    Configuration
  end

  methods
    function obj = Sequence(steps, ...
                            inputs, ...
                            outputs, ...
                            workspacePath, ...
                            outputPath, ...
                            config)
      %SEQUENCE Construct an instance of this class
      %   Detailed explanation goes here
      arguments
        steps
        inputs
        outputs
        workspacePath
        outputPath
        config
      end

      % default to empty struct if empty cell array is passed
      if isempty(config)
        obj.Configuration = struct();
      else
        obj.Configuration = config;
      end

      % add default config options
      if ~isfield(obj.Configuration, 'noCleanUp')
         obj.Configuration.noCleanUp = false;
      end
      if ~isfield(obj.Configuration, 'startStep')
         obj.Configuration.startStep = 1;
      end


      obj.Steps = steps;
      obj.Inputs = inputs;
      obj.Outputs = outputs;
      obj.WorkspacePath = workspacePath;
      obj.OutputPath = outputPath;
      obj.Results = cell(1, length(steps));
      obj.Ready = false;
      obj.Configuration = config;
    end

    function isValid = validate(obj)
      %ISVALID Summary of this method goes here
      %   check if sequence is valid

      % if inputs are not found in the workspace, abort
      for i = 1 : length(obj.Inputs)
        input = obj.Inputs{i};
        if ~exist(fullfile(input), 'file')
          fprintf('missing input %s\n', input);
          isValid = false;
          return
        end
      end
      isValid = true;
    end

    function obj = prepare(obj)
      if ~obj.Ready
        % create the workspace path
        [status, msg] = mkdir(obj.WorkspacePath);
        if (status ~= 1)
          % todo: throw error
          fprintf(msg);
        end

        % copy inputs to workspace
        for d=1:length(obj.Inputs)
          input = obj.Inputs{d};
          if ~exist(fullfile(input), 'file')
            fprintf('missing input %s\n', input);
            continue
          end
          copyfile(fullfile(input), fullfile(obj.WorkspacePath));
        end
      end
      obj.Ready = true;
    end

    function obj = cleanUpInputs(obj)
      % delete inputs from workspace
      for d=1:length(obj.Inputs)
        input = obj.Inputs{d};
        [~, fileName, fileExt] = fileparts(input);
        inputFileName = strcat(fileName, fileExt);
        inputFile = fullfile(obj.WorkspacePath, inputFileName);
        if exist(inputFile, 'file')
          delete(inputFile);
        end
      end
      obj.Ready = false;
    end

    function [obj, success] = cleanUp(obj)
      success = true;
      if obj.Configuration.noCleanUp
        return
      end
      % remove the workspace
      [status, msg] = rmdir(obj.WorkspacePath, 's');
      if (status ~= 1)
        % todo: throw error
        fprintf(msg);
        success = false;
      end
      obj.Ready = false;
    end

    function [success] = extractOutputs(obj)
      success = true;
      % create the output path
      [status, msg] = mkdir(obj.OutputPath);
      if (status ~= 1)
        % todo: throw error
        fprintf(msg);
        success = false;
      end

      % extract outputs from workspace
      for i = 1 : length(obj.Outputs)
        outputFileName = obj.Outputs{i};
        outputFile = fullfile(obj.WorkspacePath, outputFileName);
        if exist(outputFile, 'file')
          copyfile(outputFile, obj.OutputPath);
        else
          % todo: throw error
          fprintf('missing sequence output %s\n', outputFile);
          success = false;
        end
      end
    end

    function [] = addStep(obj, step)
        numSteps = length(obj.steps);
        obj.steps{1, numSteps + 1} = step;
    end

    % setters
    function obj = set.Steps(obj, steps)
      obj.Steps = steps;
    end

    function obj = set.WorkspacePath(obj, workspacePath)
      obj.WorkspacePath = workspacePath;
    end

    function obj = set.OutputPath(obj, outputPath)
      obj.OutputPath = outputPath;
    end

    function [sequenceExecution] = run(obj)
      %RUN Summary of this method goes here
      %   Detailed explanation goes here

      % create a sequence execution to track results
      sequenceExecution = SequenceExecution();

      % start execution
      timeStart = tic;
      sequenceExecution.StartTime = datetime;

      % by default succeed
      success = true;

      % check if sequence is valid
      isValid = obj.validate();
      if ~isValid
        success = false;
        % prepare execution results
        sequenceExecution.Success = success;
        sequenceExecution.Duration = toc(timeStart);
        sequenceExecution.EndTime = datetime;
        return
      end

      if ~obj.Ready
        obj.prepare();
      end

      % execute all steps sequentially
      for i = 1 : length(obj.Steps)
        step = obj.Steps{i};

        % check if we are skipping this step using start step
        startStep = obj.Configuration.startStep;
        if i < obj.Configuration.startStep
          warning('start step is %d, skipping step %d', startStep, i);
          continue;
        end

        % check if we are skipping this step manually
        skip = isfield(step.Configuration, 'skip') && ...
                       step.Configuration.skip == true;
        if skip
          warning('skipping step %d', i)
          continue;
        end

        % check if step is optional
        optional = isfield(step.Configuration, 'optional') && ...
                           step.Configuration.optional == true;

        % check if step is not valid
        isValidStep = step.validateDependencies(obj.WorkspacePath);
        if ~isValidStep
          % if not valid check if step is optional, otherwise abort
          if ~optional
            success = false;
            % prepare execution results
            sequenceExecution.Success = success;
            sequenceExecution.Result = obj.Results;
            sequenceExecution.Duration = toc(timeStart);
            sequenceExecution.EndTime = datetime;
            err = sprintf('step %d is not valid\n', i);
            sequenceExecution.Error = err;
            fprintf(err);
            return
          % warn for optional steps
          else
            warning('ignoring optional step %d after caught error: step %d is not valid', i, i);
          end
        end

        % execute step
        [status, result] = step.run(obj.WorkspacePath);
        obj.Results{i} = result;

        % check if a step did not succeed, abort
        if status ~= 0
          if ~optional
            success = false;
            % prepare execution results
            sequenceExecution.Success = success;
            sequenceExecution.Result = obj.Results;
            sequenceExecution.Duration = toc(timeStart);
            sequenceExecution.EndTime = datetime;
            % todo: throw error
            err = sprintf('step %d failed with status %d and message "%s"\n', ...
                          i, ...
                          status, ...
                          result);
            fprintf(err);
            sequenceExecution.Error = err;
            return
          else
            warning('ignoring optional step %d after caught error: step %d failed with status %d and message "%s"\n', ...
                    i, ...
                    i, ...
                    status, ...
                    result);
          end
        end
      end
      % return the list of outputs
      output = obj.Results;

      % extract outputs
      extractOutputsSuccess = obj.extractOutputs();

      if ~extractOutputsSuccess
        success = false;
      end

      % clean up
      if ~obj.Configuration.noCleanUp
        [~, cleanUpSuccess] = obj.cleanUp();
        if ~cleanUpSuccess
          success = false;
        end
      end

      % prepare execution results
      sequenceExecution.Success = success;
      sequenceExecution.Result = output;
      sequenceExecution.Duration = toc(timeStart);
      sequenceExecution.EndTime = datetime;
    end
  end
end

