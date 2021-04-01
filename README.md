# MAAST

## Matlab Runtests Build Checker
The build checker will enforce that all unit tests in the repository pass.
To run locally, execute the following from within the Matlab Command Window from the repository root directory.
```matlab
runtests('.', 'IncludeSubfolders', true);
```

## miss_hit Build Checker
This build checker will perform standard checks on repository Matlab code using Python.
Source can be found [here](https://github.com/florianschanda/miss_hit).
Documentation can be found [here](https://florianschanda.github.io/miss_hit).

To execute the checks locally, execute the following at the repository root directory.
Note that the `--fix` flag will modify files to get them into the right style.
```bash
pip install miss_hit
mh_style --fix
mh_metric
mh_lint
```
