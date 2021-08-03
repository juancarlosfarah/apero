.. include:: links.rst

------------
Installation
------------
The simplest way to get *Apéro* installed is to clone the repository

::

  $ git clone https://github.com/juancarlosfarah/apero.git

You can then add the ``/src/matlab`` folder from the directory to which you
cloned *Apéro* to your MATLAB path.

External Dependencies
=====================

*Apéro* is currently written using MATLAB R2021a (or above) and requires external
neuroimaging tools to run. What these tools are depends on the type of operations
that are executed.

By default, we include the following MATLAB toolboxes within the
``/src/matlab/external`` directory, which can be added to the MATLAB path
alongside *Apéro*.

- FreeSurfer_ (v7)
- FsFast_ (included in FreeSurfer_)
- MRIDenoisingPackage_

However, the following tools need to be installed separately:

- FSL_ (v6)

Environment Setup
=================

In order to run *Apéro* you need to specify certain variables to your path.
You can easily do this by including the following in your ``startup.m`` file.
For more information, please have a look at the
`MATLAB startup documentation <https://mathworks.com/help/matlab/ref/startup.html>`_.

.. code-block:: matlab

  % if fsl is installed somewhere other than `/usr/local/fsl/`,
  % change this first line accordingly
  fsldir = '/usr/local/fsl/';
  fsldirmpath = sprintf('%s/etc/matlab',fsldir);
  setenv('FSLDIR', fsldir);
  setenv('FSLOUTPUTTYPE', 'NIFTI_GZ');
  path(path, fsldirmpath);
  setenv('PATH', [getenv('PATH') ':/usr/local/fsl/bin']);
  clear fsldir fsldirmpath;

This code is included in the ``/src/matlab/utils/PrepareEnvironment.m`` function,
which you can copy, modify, and execute before running your Apéro script.
