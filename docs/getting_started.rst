.. include:: links.rst

---------------
Getting Started
---------------

The recommended use of *Apéro* is to add the ``/src/matlab/`` folder to your
MATLAB path and either use the default builders or create your own.

Recommended Structure
---------------------

Within your MATLAB project, we recommend you create a folder where you will
create your *Apéro* scripts and builders. You can name it as you prefer, but
we recommend the following structure:

::

  preprocessing
  ├── builders
  │ ├── configuration
  │ ├── steps
  │ ├── sequences
  │ └── pipelines
  └── scripts

Within the subfolders inside the ``builders`` subfolder, you will place your
custom builders (under the respective type). Within the ``scripts`` subfolder,
you will place your custom scripts, each of which will be the entry point for
a preprocessing pipeline.
