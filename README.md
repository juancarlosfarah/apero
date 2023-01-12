# Apéro
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-4-orange.svg?style=flat-square)](#contributors-)
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

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://juancarlosfarah.com"><img src="https://avatars.githubusercontent.com/u/1707188?v=4?s=100" width="100px;" alt="Juan Carlos Farah"/><br /><sub><b>Juan Carlos Farah</b></sub></a><br /><a href="https://github.com/juancarlosfarah/apero/commits?author=juancarlosfarah" title="Code">💻</a> <a href="https://github.com/juancarlosfarah/apero/commits?author=juancarlosfarah" title="Tests">⚠️</a> <a href="https://github.com/juancarlosfarah/apero/commits?author=juancarlosfarah" title="Documentation">📖</a> <a href="https://github.com/juancarlosfarah/apero/issues?q=author%3Ajuancarlosfarah" title="Bug reports">🐛</a> <a href="#ideas-juancarlosfarah" title="Ideas, Planning, & Feedback">🤔</a> <a href="https://github.com/juancarlosfarah/apero/pulls?q=is%3Apr+reviewed-by%3Ajuancarlosfarah" title="Reviewed Pull Requests">👀</a> <a href="#userTesting-juancarlosfarah" title="User Testing">📓</a> <a href="#maintenance-juancarlosfarah" title="Maintenance">🚧</a> <a href="#design-juancarlosfarah" title="Design">🎨</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://miplab.epfl.ch/index.php/people/eamico"><img src="https://avatars.githubusercontent.com/u/6409808?v=4?s=100" width="100px;" alt="Enrico Amico"/><br /><sub><b>Enrico Amico</b></sub></a><br /><a href="https://github.com/juancarlosfarah/apero/commits?author=eamico" title="Code">💻</a> <a href="#ideas-eamico" title="Ideas, Planning, & Feedback">🤔</a> <a href="#mentoring-eamico" title="Mentoring">🧑‍🏫</a> <a href="https://github.com/juancarlosfarah/apero/pulls?q=is%3Apr+reviewed-by%3Aeamico" title="Reviewed Pull Requests">👀</a> <a href="#userTesting-eamico" title="User Testing">📓</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/hannatolle"><img src="https://avatars.githubusercontent.com/u/88772546?v=4?s=100" width="100px;" alt="hannatolle"/><br /><sub><b>hannatolle</b></sub></a><br /><a href="https://github.com/juancarlosfarah/apero/commits?author=hannatolle" title="Code">💻</a> <a href="https://github.com/juancarlosfarah/apero/commits?author=hannatolle" title="Tests">⚠️</a> <a href="https://github.com/juancarlosfarah/apero/commits?author=hannatolle" title="Documentation">📖</a> <a href="https://github.com/juancarlosfarah/apero/issues?q=author%3Ahannatolle" title="Bug reports">🐛</a> <a href="#ideas-hannatolle" title="Ideas, Planning, & Feedback">🤔</a> <a href="https://github.com/juancarlosfarah/apero/pulls?q=is%3Apr+reviewed-by%3Ahannatolle" title="Reviewed Pull Requests">👀</a> <a href="#userTesting-hannatolle" title="User Testing">📓</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/ss1913"><img src="https://avatars.githubusercontent.com/u/69032994?v=4?s=100" width="100px;" alt="ss1913"/><br /><sub><b>ss1913</b></sub></a><br /><a href="#userTesting-ss1913" title="User Testing">📓</a> <a href="#ideas-ss1913" title="Ideas, Planning, & Feedback">🤔</a> <a href="https://github.com/juancarlosfarah/apero/issues?q=author%3Ass1913" title="Bug reports">🐛</a> <a href="#promotion-ss1913" title="Promotion">📣</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->
