# Apéro

[![Documentation Status](https://readthedocs.org/projects/apero/badge/?version=latest)](https://apero.readthedocs.io/en/latest/?badge=latest)
[![Conventional Commits](https://img.shields.io/badge/conventional%20commits-1.0.0-yellow.svg)](https://conventionalcommits.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A Preprocessing Pipeline Builder for Neuroimaging Data

## Motivation 

We all know that preprocessing neuroimaging data is hard and tedious. We created
Apéro to make this process easier and to promote reliable preprocessing pipelines
that can help make research reproducible. This work builds on the preprocessing
pipeline used in [Amico et al., NeuroImage (2017)](https://doi.org/10.1016/j.neuroimage.2017.01.020).

## Command Line

If you are running `matlab` from the command line, you can run your scripts
using a command similar to the one below.  

```bash
matlab -nodisplay -nosplash -nodesktop -r "try, run('/path/to/scripts/myScript.m'); catch me, e = getReport(me); fprintf('%s\n', e); end; exit;"
```


## Contributors

- Juan Carlos Farah
- Enrico Amico
- Hanna Tolle

