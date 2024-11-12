## Release summary

- Following the previous reviews, we fixed the invalid URLs (also in the vignette) and added the URI protocol when relevant. Apologies for these troubles.  
- We fixed a bug to preserve compatibility with GDAL 3.9 and slightly adjust an error message. We also updated the Open Street Map databases within the package. 

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
