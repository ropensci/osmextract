## Release summary

- We fixed several bugs and included a couple of new functions. The details are listed in the NEWS file.  

## Test environments

- local Windows, R 4.3.1
- Github Actions: ubuntu-latest (r-release)

## R CMD check results

I see two notes. The first one is related to the updated email address for the maintainer of this package. In fact, as already explained by email, I decided to adjust the email address associated to this package since I recently changed university affiliation. The second one is related to the package size and reads as follows: 

❯ checking installed package size ... NOTE
  installed size is  5.2Mb
  sub-directories of 1Mb or more:
    data   3.5Mb
    help   1.1Mb

Unfortunately, the "*_zones" files represent the building blocks of this package and I'm not sure how to reduce their size since they are used to perform crucial spatial matching operations. According to my experience, these objects are not frequently updated and I expect that they will never grow much larger than this. 
