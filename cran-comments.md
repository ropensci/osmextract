## Release summary

- We modified the built-in data objects to adapt our package to `sf` version 1.0.0 and, in particular, the new `s2` package for spherical geometry operations. 
- We modified several functions, examples, and tests and implemented several new functionalities. The details are listed in the NEWS file. 
- The tests that require an internet connection are now skipped on CRAN checks. 

## Test environments

- local Windows install, R 4.0.6
- GHA windows-latest (r-release)
- GHA macOS-latest (r-release)
- GHA ubuntu-20.04 (r-release)
- GHA ubuntu-20.04 (r-devel)

## R CMD check results

0 errors √ | 0 warnings √ | 1 note x
