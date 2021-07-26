classdef Sequence
  %SEQUENCE Summary of this class goes here
  %   Detailed explanation goes here

  properties
    Steps
    Inputs
    Outputs
    WorkspacePath
    OutputPath
    NoCleanUp
    Results
    Ready
  end

  methods
    function obj = Sequence(steps, ...
                            inputs, ...
                            outputs, ...
                            workspacePath, ...
                            outputPath, ...
                            noCleanUp)
      %SEQUENCE Construct an instance of this class
      %   Detailed explanation goes here
      obj.Steps = steps;
      obj.Inputs = inputs;
      obj.Outputs = outputs;
      obj.WorkspacePath = workspacePath;
      obj.OutputPath = outputPath;
      obj.NoCleanUp = noCleanUp;
      obj.Results = cell(1, length(steps));
      obj.Ready = false;
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

    function obj = cleanUp(obj)
      if obj.NoCleanUp
        return
      end
      % remove the workspace
      [status, msg] = rmdir(obj.WorkspacePath, 's');
      if (status ~= 1)
        % todo: throw error
        fprintf(msg);
      end
      obj.Ready = false;
    end

    function [] = extractOutputs(obj)
      % create the output path
      [status, msg] = mkdir(obj.OutputPath);
      if (status ~= 1)
        % todo: throw error
        disp(msg);
      end

      % extract outputs from workspace
      for i = 1 : length(obj.Outputs)
        outputFileName = obj.Outputs{i};
        outputFile = fullfile(obj.WorkspacePath, outputFileName);
        if exist(outputFile, 'file')
          copyfile(outputFile, obj.OutputPath);
        else
          fprintf('missing output %s\n', outputFile);
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

        % abort if step is not valid
        isValidStep = step.validateDependencies(obj.WorkspacePath);
        if ~isValidStep
          success = false;
          % prepare execution results
          sequenceExecution.Success = success;
          sequenceExecution.Result = obj.Results;
          sequenceExecution.Duration = toc(timeStart);
          sequenceExecution.EndTime = datetime;
          error = sprintf('step %s is not valid\n', i);
          sequenceExecution.Error = error;
          fprintf(error);
          return
        end

        % execute step
        [status, result] = step.run(obj.WorkspacePath);
        obj.Results{i} = result;

        % if a step does not succeed, abort
        % todo: have "optional" steps
        if status ~= 0
          success = false;
          % prepare execution results
          sequenceExecution.Success = success;
          sequenceExecution.Result = obj.Results;
          sequenceExecution.Duration = toc(timeStart);
          sequenceExecution.EndTime = datetime;
          % todo: throw error
          error = sprintf('step %s failed with status %s and message %s\n', ...
                          i, ...
                          status, ...
                          result);
          fprintf(error);
          sequenceExecution.Error = error;
          fprintf(error);
          return
        end
      end
      % return the list of outputs
      output = obj.Results;

      % extract outputs
      obj.extractOutputs();

      % clean up
      if ~obj.NoCleanUp
        obj.cleanUp();
      end

      % prepare execution results
      sequenceExecution.Success = success;
      sequenceExecution.Result = output;
      sequenceExecution.Duration = toc(timeStart);
      sequenceExecution.EndTime = datetime;
    end
  end
end

