## Release summary

- Fixed the invalid language tag in DESCRIPTION file. 
- Fixed a bug to preserve compatibility with GDAL 3.10. 
- Several minor improvements. 

## Test environments

- local Windows, R 4.3.1
- Github Actions: ubuntu-latest (r-release)

## R CMD check results

I see only one note reported below:  

> checking installed package size ... NOTE
  sub-directories of 1Mb or more:
    data   3.5Mb
    help   1.1Mb

The "*_zones" files represent the building blocks of this package and I'm not sure how to reduce their size since they are used to perform crucial spatial matching operations. However these objects are not frequently updated and I expect that they will never grow much larger than this. 
