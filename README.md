# MAAST

## Matlab Continuous Integration

This build checker does the following.
1. Executes Matlab's `checkcode` function on all repository files and asserts no suggestions.
2. Finds all Matlab tests in the repository, executes Matlab's `runtests`, then reports the results.
3. If their is a pull request associated with the push, a unit test coverage report is attached to the report.

This build checker will also perform standard checks on repository Matlab code using Python with MISS_HIT.
Source can be found [here](https://github.com/florianschanda/miss_hit).
Documentation can be found [here](https://florianschanda.github.io/miss_hit).

To run the all the checks locally, one must execute the following from bash at the repository root directory (note the `--fix` will automatically fix style issues)
```bash
mh_style --process-slx --fix
mh_metric --ci
mh_lint
```
and the following from Matlab at the repository root directory (with all the appropriate Matlab path setup).
```matlab
addpath('.github/workflows');
matlab_checkcode_on_directory('.');
matlab_runtests_on_directory('.');
