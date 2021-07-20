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
          disp(msg);
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
      if ~obj.NoCleanUp
        return
      end
      delete(fullfile(obj.WorkspacePath, '*'));
      obj.Ready = false;
    end

    function [] = extractOutputs(obj)
      % extract outputs from workspace
      for o = 1 : length(obj.Outputs)
        outputFileName = obj.Outputs{d};
        outputFile = fullfile(obj.WorkspacePath, outputFileName);
        if exist(outputFile, 'file')
          copyfile(outputFile, fullfile(obj.OutputPath));
        end
      end
    end

    function [] = addStep(obj, step)
        numSteps = length(obj.steps);
        obj.steps{1, numSteps + 1} = step;
    end

    % setters
    function obj = set.Steps(obj, ~)
    end

    function obj = set.WorkspacePath(obj, ~)
    end

    function obj = set.OutputPath(obj, ~)
    end

    function [success, output] = run(obj)
      %RUN Summary of this method goes here
      %   Detailed explanation goes here

      % check if sequence is valid
      isValid = obj.validate();
      if ~isValid
        success = false;
        return
      end

      if ~obj.Ready
        obj.prepare();
      end

      % execute all steps sequentially
      % todo: allow parallel steps
      for i=1:length(obj.Steps)
        step = obj.Steps{i};

        % abort if step is not valid
        isValidStep = step.isValid();
        if ~isValidStep
          success = false;
          return
        end

        % execute step
        [stepSuccess, result] = step.run(obj.WorkspacePath);
        obj.Results{i} = result;

        % if a step does not succeed, abort
        % todo: have "optional" steps
        if ~stepSuccess
          success = false;
          return
        end
      end
      % return the list of outputs
      output = obj.Results;
      
      % clean up
      if ~obj.NoCleanUp
        obj.cleanUp()
      end
    end
  end
end

