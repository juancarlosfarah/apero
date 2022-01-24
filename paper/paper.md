---
title: 'Apéro: A Preprocessing Pipeline Builder for Neuroimaging Data'
tags:
- MATLAB
- neuroimaging
- preprocessing
- pipeline builder
- neuroscience
authors:
- name: Juan Carlos Farah [corresponding author]
  orcid: 0000-0002-2477-4196
  affiliation: 1
- name: Hanna Tolle
  affiliation: 2
- name: Denis Gillet
  orcid: 0000-0002-2570-929X
  affiliation: 1
- name: Enrico Amico
  orcid: 0000-0001-6705-9689
  affiliation: 1
affiliations:
- name: École Polytechnique Fédérale de Lausanne
  index: 1
- name: University of Sussex
  index: 2
date: 24 January 2022
bibliography: paper.bib
---

# Summary
Preprocessing represents the first step of every meaningful neuroimaging data analysis.
Powerful software packages such as FSL [@jenkinson2012fsl], Freesurfer (ref) and SPM (ref) support a number of operations for preprocessing brain data.
However, the variety of tools also makes it harder to keep preprocessing pipelines tidy and interpretable.
Furthermore, since preprocessing pipelines need to be adjusted to the data, and different datasets may come with different file labelings, reusing an already-developed pipeline tends to be time-consuming and tedious.
Finally, while the way how preprocessing is done can have a substantial influence on the results of the study, standardized protocols are currently not available, rendering neuroscience less reproducible.

Apéro is a MATLAB toolbox which provides a uniform operating interface for calling commonly-used preprocessing software.
It was designed to be (i) easy to use, ensuring a steep learning curve for first users; (ii) easy to adjust, considerably simplifying the process of finetuning pipelines and applying them to different datasets; (iii) flexible, supporting various data formats including but not limited to BIDS. Lastly, Apéro comes with default preprocessing protocols which may contribute to standardization while still allowing for customization.

# Statement of Need
TODO

# Interface Design
In Apéro, preprocessing pipelines are created from building blocks.
The smallest building block class is an **operation** such as thresholding.
An operation forms the core element of a **step**, the next higher-level buidling block, which checks for the availability of dependencies before executing the operation.
Finally, a **sequence** comprises several steps in a specific order, and a **configuration** is a structure, which stores all the adjustable information including paths to input, output and workspace directories, subject IDs and step-level configurations such as a desired threshold.

# Use and Features
Running a preprocessing pipeline with Apéro requires the user to prepare three types of MATLAB (.m) files: a function that builds a sequence, a function that builds a configuration, and a script that builds and executes the sequence using the given configuration.
Apéro comes with a number of templates and default builder functions, rendering the preparation of these three files quick and straight-forward.

Figure 1 shows the typical structure of a sequence builder function.
The function outputs a sequence and takes as input the name of a subject and the configuration.
As a sequence is comprised of steps, the main part of the sequence builder function is typically dedicated to building steps.

Steps are built by defining the corresponding configurations, dependencies and outputs, before creating an instance of the step class with the desired operation (here, ThresholdVolume).
Static configurations are specified in the separate configuration builder, whereas dynamic configurations (e.g. input and output volumes, which include the subject name), are specified within the sequence builder.

After all steps are built, the inputs for creating the sequence class are defined.
These inputs include the steps set up in order, the outputs that should be copied from the workspace to the output directory, as well as the subject inputs required to start the sequence and the paths to the subject workspace and output directories.

# References
