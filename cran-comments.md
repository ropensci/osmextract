## Release summary

- Added a new argument named 'version' to 'oe_match()'
- Changed the maintainer's email address. I've already sent an email to CRAN-submissions@R-project.org explaining the reasons behind this change.  

## Test environments

- local Windows, R 4.4.2
- Github Actions: ubuntu-latest (r-release)

## R CMD check results

I see only one note reported below:  

> checking installed package size ... NOTE
  sub-directories of 1Mb or more:
    data   3.5Mb
    help   1.1Mb

The "*_zones" files represent the building blocks of this package and I'm not sure how to reduce their size since they are used to perform crucial spatial matching operations. However these objects are not frequently updated and I expect that they will never grow much larger than this. 
