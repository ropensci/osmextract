## Release summary

- Modified the default directory where OSM extracts are saved
- Modified the behaviour of oe_get() when place is an sf/sfc object and synch the GDAL CONFIG file
- Bumped minimum R version to 4.1

## Test environments

- local Windows, R 4.4.2
- Github Actions: ubuntu-latest (r-release); ubuntu-latest (R 4.1); MacOS-latest (r-release)

## R CMD check results

I see only one note reported below:  

> checking installed package size ... 
     installed size is  5.4Mb
     sub-directories of 1Mb or more:
       data   3.6Mb
       help   1.1Mb

The "*_zones" files represent the building blocks of this package and I'm not sure how to reduce their size since they are used to perform crucial spatial matching operations. However these objects are not frequently updated and I expect that they will never grow much larger than this. 

## revdepcheck results

We checked 1 reverse dependencies, comparing R CMD check results across CRAN and dev versions of this package.

 * We saw 0 new problems
 * We failed to check 0 packages
