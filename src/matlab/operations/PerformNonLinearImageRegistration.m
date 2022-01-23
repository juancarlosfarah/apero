function [status, result, command] = PerformNonLinearImageRegistration(pathToWorkspace, ...
                                                              config)
%PERFORMNONLINEARIMAGEREGISTRATION Perform nonlinear image registration using `fnirt`.
%   Uses `fnirt` to perform nonlinear image registration.
%   
%   If operation fails, returns a nonzero value in status and an
%   explanatory message in result.
%
%   Input:
%   - pathToWorkspace:  Path to the workspace.
%   - config:           Configuration to be used in the operation.
%
%   Output:
%   - status:  Status returned by system call.
%   - result:  Result returned by system call.
%
% Optional arguments (You may optionally specify one or more of):
% 	--aff		name of file containing affine transform
% 	--inwarp	name of file containing initial non-linear warps
% 	--intin		name of file/files containing initial intensity mapping
% 	--fout		name of output file with field
% 	--jout		name of file for writing out the Jacobian of the field (for diagnostic or VBM purposes)
% 	--refout	name of file for writing out intensity modulated --ref (for diagnostic purposes)
% 	--intout	name of files for writing information pertaining to intensity mapping
% 	--logout	Name of log-file
% 	--config	Name of config file specifying command line arguments
% 	--refmask	name of file with mask in reference space
% 	--inmask	name of file with mask in input image space
% 	--applyrefmask	Use specified refmask if set, default 1 (true)
% 	--applyinmask	Use specified inmask if set, default 1 (true)
% 	--imprefm	If =1, use implicit masking based on value in --ref image. Default =1
% 	--impinm	If =1, use implicit masking based on value in --in image, Default =1
% 	--imprefval	Value to mask out in --ref image. Default =0.0
% 	--impinval	Value to mask out in --in image. Default =0.0
% 	--minmet	non-linear minimisation method [lm | scg] (Levenberg-Marquardt or Scaled Conjugate Gradient)
% 	--miter		Max # of non-linear iterations, default 5,5,5,5
% 	--subsamp	sub-sampling scheme, default 4,2,1,1
% 	--warpres	(approximate) resolution (in mm) of warp basis in x-, y- and z-direction, default 10,10,10
% 	--splineorder	Order of spline, 2->Quadratic spline, 3->Cubic spline. Default=3
% 	--infwhm	FWHM (in mm) of gaussian smoothing kernel for input volume, default 6,4,2,2
% 	--reffwhm	FWHM (in mm) of gaussian smoothing kernel for ref volume, default 4,2,0,0
% 	--regmod	Model for regularisation of warp-field [membrane_energy bending_energy], default bending_energy
% 	--lambda	Weight of regularisation, default depending on --ssqlambda and --regmod switches. See user documentation.
% 	--ssqlambda	If set (=1), lambda is weighted by current ssq, default 1
% 	--jacrange	Allowed range of Jacobian determinants, default 0.01,100.0
% 	--refderiv	If =1, ref image is used to calculate derivatives. Default =0
% 	--intmod	Model for intensity-mapping [none global_linear global_non_linear local_linear global_non_linear_with_bias local_non_linear]
% 	--intorder	Order of polynomial for mapping intensities, default 5
% 	--biasres	Resolution (in mm) of bias-field modelling local intensities, default 50,50,50
% 	--biaslambda	Weight of regularisation for bias-field, default 10000
% 	--estint	Estimate intensity-mapping if set, default 1 (true)
% 	--numprec	Precision for representing Hessian, double or float. Default double

arguments
  pathToWorkspace char = '.'
  % name of input image
  config.inputImage char
  % name of reference image
  config.referenceImage char
  % name of output image
  config.outputImage char = ''
  % name of output file with field coefficients
  config.outputFieldCoefficients char = ''
  % image interpolation model
  config.interp char {mustBeMember(config.interp, { ...
    'linear', ...
    'spline' ...
  })} = 'linear'
  config.verbose logical = false
  config.v logical = false
end

%% main command
fullInputImage = fullfile(pathToWorkspace, config.inputImage);
fullReferenceImage = fullfile(pathToWorkspace, config.referenceImage);
command = 'fnirt --in=%s --ref=%s';
command = sprintf(command, fullInputImage, fullReferenceImage);

%% options
% name of output image
if ~isempty(config.outputImage)
  fullOutputImage = fullfile(pathToWorkspace, config.outputImage);
  command = sprintf('%s --iout=%s', command, fullOutputImage);
end

% name of output file for field coefficients
if ~isempty(config.outputFieldCoefficients)
  fullOutputFieldCoefficients = fullfile(pathToWorkspace, ...
                                         config.outputFieldCoefficients);
  command = sprintf('%s --cout=%s', command, fullOutputFieldCoefficients);
end

% image interpolation model
if config.interp
  command = sprintf('%s --interp=%s', command, config.interp);
end

% verbose (switch on diagnostic messages)
if config.verbose || config.v
  command = sprintf('%s -v', command);
end

%% execute
[status, result] = CallSystem(command, config.verbose);

end

