function [status, result] = CallSystem(sentence, verbose)
%CALLSYSTEM This function executes a system call.
%   Input:
%   - sentence  Sentence to execute.
%   - verbose:  Boolean indicating verbosity.
%
%   Output:
%   - status:   Status of the system call.
%   - result:   Result of the system call.

% print output from system calls if verbose
if verbose
  systemOutput = '-echo';
end

[status, result] = system(sentence, systemOutput);

end
