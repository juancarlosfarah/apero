.. include:: links.rst

--------
Concepts
--------

The recommended use of *Apéro* is to add the ``/src/matlab/`` folder to your
MATLAB path and either use the default builders or create your own.


Building Blocks
---------------

*Apéro* is built on the idea of grouping operations into reusable components.
Operations are therefore the core units of this toolbox. In order to make
operations more flexible and reliable, they are packaged into a ``Step`` object,
which will execute the operation when run. In turn, steps can be grouped into a
``Sequence``, within which they are executed one after the other. A ``Pipeline``
groups a set of sequences, which can be run sequentially or in parallel. A
``Pipeline`` is primarily used to run the same ``Sequence`` across a group of
subjects. Finally, multiple pipelines can be executed within a script, which
is the entrypoint for an Apéro preprocessing pipeline.

Operations
==========

Operations are therefore the units of *Apéro*. *Apéro* comes with a wide array
of default operations that use other libraries underneath (e.g. FSL_,
MRIDenoisingPackage_, MRtrix3_, Freesurfer_). An operation is a function
always has the following signature:

::

  OperationName(pathToWorkspace, params, config)

The ``params`` and ``config`` arguments are structs the capture what the
operation requires.

Here is a sample operation that binarizes an image using `fslmaths`.

.. literalinclude:: ../src/matlab/operations/Binarize.m
   :language: matlab


Steps
=====

A step is the smallest processing unit in our toolkit. It consists primarily of:

* One operation: a lambda function to be called at runtime.
* Zero or more dependencies: files required to run the operation.
* Zero or more outputs: used to check for “clobbering”.
* Structs containing parameters and configuration options.

Before running the operation, the presence of dependencies and outputs is checked.

Sequences
=========

A sequence consists of steps to be executed to produce a set of outputs given a
set of inputs. Its main components are:

* A set of steps to execute.
* A set of inputs to copy into the workspace.
* A set of outputs to extract from the workspace.

All steps are executed in the same workspace. Outputs are extracted to a
specified path and the workspace is (optionally) cleared.

Pipelines
=========

A pipeline defines sequences to be executed, in order or in parallel, using a
set of input sources. This is most applicable to apply the same sequence to a
dataset comprising a set of subjects, where each subject’s data has a similar structure.
Its main component is a set of sequences to execute.

Scripts
=======

A script brings together a set of pipelines that should be executed, in order.
This is most useful to execute pipelines that are applicable to a dataset and
perform parallel operations that might be dependent on intermediate steps.
Specifically, a script makes calls to pipeline builders (which are described
below) to adapt pipelines according to the data in question.
When executing an Apéro preprocessing pipeline, the entrypoint to the
pipeline is a script. If you haven't setup the environment within ``startup.m``,
then you will have to call ``/src/matlab/utils/`PrepareEnvironment.m`` at the
top of each script file.


Configurations
==============
Currently, configurations are simply structs that can be passed down from the
script, all the way down to the operation, or applied directly at any level
(``Pipeline``, ``Sequence``, ``Step``).
Configurations can be split, nested, and composed using builders.


Builders
--------

*Apéro* has building blocks, but building blocks are not as useful without
builders! To actually build pipelines, *Apéro* requires builders.
Builders are helper functions that use the building blocks to scaffold full,
reusable pipelines. Although *Apéro* comes with default builders, builders are
the core of the toolkit's extensibility and here is where end users come in.
Builders can be created at different levels to factor out logic and make code
reusable.

* **Step Builders:** Help create reusable steps.
* **Sequence Builders:** Bring together steps to create sequences.
* **Pipeline Builders:** Allow users to build full reusable pipelines.
* **Configuration Builders:** Easily modify how pipelines, sequences, and steps are run.

Builders can also be shared back with the community, so feel free to send a pull
request if you write a builder that you think might be useful!

Executions
----------

Some *Apéro* building blocks have an *execution* equivalent that optionally
stores the results of an execution.

* ``StepExecution``
* ``SequenceExecution``
* ``PipelineExecution``

They also capture metadata such as errors and duration.
