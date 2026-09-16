## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

## Test environments

* macOS, local R installation
* R-hub Linux, R-devel
* R-hub macOS ARM64, R-devel
* R-hub Windows, R-devel
* R-hub Ubuntu release
* R-hub nosuggests
* win-builder, R-devel

## Additional comments

This is the first CRAN submission of rjsf.

rjsf provides an R interface to the Python Jump-Switch-Flow
implementation. The Python backend is an optional external system
requirement for running simulations. Tests and examples that require
the Python backend are handled gracefully when it is unavailable.
