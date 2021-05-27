# osmextract (development version)

### MAJOR CHANGES

* The `oe_get_keys()` function can be used to extract the values associated to all or some keys. We also defined an ad-hoc printing method, and fixed several bugs. The examples were improved. Moreover, now the function tries to match an input `zone` with one of the OSM extracts previously downloaded (#201 and #196). 
* If the parameter `place` represents an `sf`/`sfc`/`bbox` object with missing CRS, then `oe_match()` raises a warning message and sets `CRS = 4326`. This has relevant consequences on other functions (like `oe_get()`) that wrap `oe_match()`. 
* Starting from `sf` 0.9.9, the function `oe_vectortranslate()` stops with an error when there is a problem in the argument `vectortranslate_options` and `quiet = FALSE` (instead of crashing the `R` session). See [here](https://github.com/r-spatial/sf/issues/1680) for more details. 
* The options `c("-f", "GPKG", "-overwrite", "-oo", "CONFIG_FILE=", "-lco", "GEOMETRY_NAME=geometry")` are always added to `vectortranslate_options` argument unless the user explicitly sets different default parameters (#200). We believe those are sensible default options and can help users creating less verbose specifications for `ogr2ogr` utility. 

### BUG FIXES

* The parameter `force_vectortranslate` is checked before reading the layers of an existing `gpkg` file. If `force_vectortranslate` is `TRUE`, then `oe_vectortranslate()` doesn't check the existing layers. This is important for user that run `oe_vectortranslate()` after stopping the vectortranslate process.  

### MINOR IMPROVEMENTS

* The arguments passed to `oe_read()` via `...` are compared with the formals of `st_read.character` and `st_as_sf.data.frame`. 
* Added a new method to `oe_match` for `bbox` objects (#185).
* The `oe_get_keys()` function can be applied to `.osm.pbf` objects (#188). 

### DOCUMENTATION FIXES

* Improved several examples and fixed a small bug in the documentation of `oe_match()`.
* Fix several typos in the vignettes and docs. 

### OTHERS

* Created a new space in the github repo named _Discussion_ to have conversations, ask questions and post answers without opening issues. Link: https://github.com/ropensci/osmextract/discussions.
* Tests that require an internet connection are now skipped on CRAN (#189). 

# osmextract 0.2.1

This is a minor release. 

* We modified several examples and tests to fix several errors noticed during CRAN tests (#175). 

# osmextract 0.2.0

Published on CRAN! 

### NEW FEATURES

* Add a `level` parameter to `oe_match()`. It is used to choose between multiple hierarchically nested OSM extracts. The default behaviour is to select the smallest administrative unit (#160).
* Modify the behaviour of `oe_match()`. The function checks all implemented providers in case the input `place` is not matched with any geographical zone for the chosen provider (#155).
* Add a simple interface to Nominatim API that enables `oe_match()` to geolocate text strings that cannot be found in the providers (#155). 

### MINOR IMPROVEMENTS

* Normalise the paths managed by `oe_download_directory` and `oe_download` (#150 and #161) 
* `oe_get_keys` returns an informative error when there is no other_tags field in the input file (#158)

### BUG FIXES

* Fix the structure of `geofabrik_zones` object (#167)
* Fix warning messages related to ... in `oe_get()` (#152)

### DOCUMENTATION FIXES

* Simplify several warning messages in case of spatial matching
* Simplify startup message (#156)
* Add more details related to download timeouts (#145)
* Documented values returned by `oe_find()` and `oe_search()`

# osmextract 0.1.0

* Finish development of the main functions
* Submit to rOpenSci for peer-review
