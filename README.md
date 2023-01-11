# Apéro
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-1-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

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
<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://miplab.epfl.ch/index.php/people/eamico"><img src="https://avatars.githubusercontent.com/u/6409808?v=4?s=100" width="100px;" alt="Enrico Amico"/><br /><sub><b>Enrico Amico</b></sub></a><br /><a href="https://github.com/juancarlosfarah/apero/commits?author=eamico" title="Code">💻</a> <a href="#ideas-eamico" title="Ideas, Planning, & Feedback">🤔</a> <a href="#mentoring-eamico" title="Mentoring">🧑‍🏫</a> <a href="https://github.com/juancarlosfarah/apero/pulls?q=is%3Apr+reviewed-by%3Aeamico" title="Reviewed Pull Requests">👀</a> <a href="#userTesting-eamico" title="User Testing">📓</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->
- Enrico Amico
- Hanna Tolle

