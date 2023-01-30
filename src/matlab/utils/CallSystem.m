function [status, result] = CallSystem(sentence, verbose)
%CALLSYSTEM This function executes a system call.
%   
%   Return status and result. A status of 0 signals everything went fine
%   If operation fails, returns a nonzero value in status and an
%   explanatory message in result.
%
%   Input:
%   - sentence  Sentence to execute.
%   - verbose:  Boolean indicating verbosity.
%
%   Output:
%   - status:   Status of the system call.
%   - result:   Result of the system call.

arguments
  sentence string
  verbose logical = false
end

% print output from system calls if verbose
if verbose
  systemOutput = '-echo';
  
  % also log the sentence that will be executed
  fprintf('executing command: %s\n', sentence);

  % if operation fails system returns a nonzero value in
  % status and an explanatory message in result
  [status, result] = system(sentence, systemOutput);
else

  % if operation fails system returns a nonzero value in
  % status and an explanatory message in result
  [status, result] = system(sentence);
end

end
