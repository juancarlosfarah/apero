% function [sequence] = BuildSequence(inputs, ...
%                                     subjectName, ...
%                                     pathToWorkspace, ...
%                                     pathToOutput, ...
%                                     config)
                                  
function [sequence] = BuildSequence(sequenceDefinition)
%BUILDSEQUENCE Example of a sequence builder for brain extraction.
%   This sequence builder runs brain extraction of a T1w image.
%   
%   Input:
%   - inputs:           Inputs that will be copied into the workspace.
%   - pathToWorkspace:  Path to the sequence's workspace.
%   - pathToOutput:     Path to where we will output the data.
%
%   Output:
%   - sequence:  Built sequence.


numSteps = length(sequenceDefinition.steps);

sequence = Sequence({}, ...
                    sequenceDefinition.inputs, ...
                    sequenceDefinition.outputs, ...
                    sequenceDefinition.pathToWorkspace, ...
                    sequenceDefinition.pathToOutput, ...
                    sequenceDefinition.configuration);

% create each step
for i = 1 : numSteps
  stepDefinition = sequenceDefinition.steps{i};
  step =  Step(stepDefinition.operation, ...
               stepDefinition.configuration, ...
               stepDefinition.dependencies, ...
               stepDefinition.outputs);
  sequence.addStep(step);
end


% these files will be copied from the workspace to the output path
outputs = { sprintf('%s_T1w.nii.gz', subjectName)  ...
            sprintf('%s_T1w_brain.nii.gz', subjectName), ...
            sprintf('%s_T1w_brain_mask_filled.nii.gz', subjectName), ...
            sprintf('%s.anat/T1_subcort_seg.nii.gz', subjectName), ...
            sprintf('%s.anat/T1_biascorr.nii.gz', subjectName), ...
            sprintf('%s_T1w_brain_trim.nii.gz', subjectName) };


end
