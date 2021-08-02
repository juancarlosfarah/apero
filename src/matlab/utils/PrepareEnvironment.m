function [] = PrepareEnvironment()
%PREPAREENVIRONMENT Prepares the environment.
%   Prepares the environment for Apéro to run. If fsl is installed
%   somewhere other than `/usr/local/fsl/`, change `fsldir` accordingly.

fsldir = '/usr/local/fsl/';
fsldirmpath = sprintf('%s/etc/matlab',fsldir);
setenv('FSLDIR', fsldir);
setenv('FSLOUTPUTTYPE', 'NIFTI_GZ');
path(path, fsldirmpath);
setenv('PATH', [getenv('PATH') ':/usr/local/fsl/bin']);
clear fsldir fsldirmpath;

end
