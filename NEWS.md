# osmextract (development version)

### MAJOR CHANGES

* Bump minimum R version from 3.5.0 to 3.6.0 since that's a requirement for one of our indirect dependencies (i.e. [evaluate](https://cran.r-project.org/package=evaluate)). 
* Adjusted the SQL syntax used inside `oe_get_network` so that the queries are compatible with GDAL 3.10 ([#298](https://github.com/ropensci/osmextract/issues/291)). 
* The output of `oe_get_network` does not drop elements tagged as `access = 'no'` as long as the `foot`/`bicycle`/`motor_vehicle` (according to the chosen mode of transport) key is equal to `yes`, `permissive`, or `designated` ([#289](https://github.com/ropensci/osmextract/issues/289)). 

### MINOR CHANGES

* Updated the `osmconf.ini` file to be in synch with the GDAL version.
* Added `oneway` as column by default when using `oe_get_network(mode = "driving")`, which indicates if a link represents an uni-directional road ([#296](https://github.com/ropensci/osmextract/issues/296))
* Furthermore, `oe_get_network(mode = "driving")` also include the `motor_vehicle` field (see [#303](https://github.com/ropensci/osmextract/pull/303)). 

# osmextract 0.5.1

### MINOR CHANGES

* Updated the code in the main vignette to fix a bug in the `ogr2ogr` options detected by GDAL v3.9 ([#291](https://github.com/ropensci/osmextract/issues/291)). 
* More informative error message in case of malformed query ([#290](https://github.com/ropensci/osmextract/issues/290)). 
* Updated the Open Street Map providers. In particular: 
  - The bbbike databse has a new area: Los Angeles
  - The geofabrik database has a new area: United Kingdom
  - The openstreetmap.fr database has 51 new areas: Asia/Europe/Philippines and its [subregions](https://download.openstreetmap.fr/polygons/asia/philippines/)/Turkey and its [subregions](https://download.openstreetmap.fr/polygons/europe/turkey/)/Portugal's [subregions](https://download.openstreetmap.fr/polygons/europe/portugal/)/Tuvalu/Chukotka Autonomous Okrug/Fiji/France Metro Dom Com Nc/Kiribati. 

# osmextract 0.5.0

### MAJOR CHANGES
* Fixed a bug in `oe_match()` that occurred every time the function found an exact match between the input `place` and a non-default OSM data provider (i.e. everything but Geofabrik). In those cases, the downloaded file was named as `geofabrik_xyz.osm.pbf` instead of `differentprovider_xyz.osm.pbf`. Reported by @GretaTimaite, thanks. See [#246](https://github.com/ropensci/osmextract/pull/246). This is a major bug and, for safety, we suggest you erase all `.pbf` and `.gpkg` files currently stored in the persistent download directory (see also `oe_clean()`). 
* Fixed a bug in `oe_get_keys()` that occurred when the value for a given key was either empty or equal to `\n` ([#250](https://github.com/ropensci/osmextract/issues/250)). 
* Fixed a bug in `oe_vectortranslate()` that occurred when the attributes specified in the `extra_tags` argument included the character `:`. In fact, the presence of attributes like "lanes:left" always triggered the vectortranslate operations ([#260](https://github.com/ropensci/osmextract/issues/260)).
* We implemented a new function named `oe_get_boundary()` that can be used to obtain administrative geographical boundaries of a given area ([#206](https://github.com/ropensci/osmextract/issues/206)). 
* Added a new function named `read_poly()` to read `.poly` files ([#277](https://github.com/ropensci/osmextract/issues/277)). 
* All the databases storing the data for the supported providers were updated. For simplicity, some fields were removed from the saved objects. More precisely, we removed the columns `pbf.internal`, `history`, `taginfo`, `updates`, `bz2`, and `shp` from `geofabrik_zones`; `last_modified`, `type`, `base_url` and `poly_url` from `bbbike_zones`. 
* The function `oe_match_pattern()` now accepts `numeric`/`sfc`/`bbox`/`sf` inputs, following the same logic as `oe_match()` ([#266](https://github.com/ropensci/osmextract/issues/266)). 

### MINOR CHANGES
* The `boundary` argument can be specified using `bbox` objects. The `bbox` object is converted to `sfc` object with `sf::st_as_sfc()` and preserves the same CRS. 
* Added a more informative error message when `oe_get()` or `oe_read()` are run with empty or unnamed arguments in `...` ([#234](https://github.com/ropensci/osmextract/issues/234) and [#241](https://github.com/ropensci/osmextract/issues/241)).
* The function `oe_get_keys()` gains a new argument named `download_directory` that can be used to specify the path of the directory that stores the `.osm.pbf` files. 
* Included a new function named `oe_clean()` to remove all `.pbf` and `.gpkg` files stored in a given directory. Default value is `oe_download_directory()`. 
* Added a message to `oe_download()` and removed a warning from `oe_read()`. The message is printed every time a user downloads a new OSM extract from a certain provider, whereas the warning used to be raised when a given `query` selected a layer different from the `layer` argument ([#240](https://github.com/ropensci/osmextract/issues/240)). 
* Added two new parameters to `oe_find()` named `return_pbf` and `return_gpkg`. They can be used to select which file formats should the function return ([#253](https://github.com/ropensci/osmextract/pull/253)). 
* Added a more informative error message in case `oe_download()` fails, explaining that partially downloaded `.pbf` files should be removed to avoid problems while running other functions ([#221](https://github.com/ropensci/osmextract/issues/221)). 
* We are experimenting with the new (i.e. third edition) features of `testthat` and we implemented the so-called test-fixtures to run tests in a more isolated environment ([#255](https://github.com/ropensci/osmextract/pull/255)). This is however still experimental for us.
* Added more informative error and warning messages to `oe_get_keys()` ([#251](https://github.com/ropensci/osmextract/issues/251)).
* The file path returned by `oe_download()` is specified using `/` instead of `\\` separator on Windows. 
* `oe_download()` takes into account the `timeout` option again. Unfortunately, we forgot to adjust the code when switching from `download.file` to `httr`. 
* The `oe_vectortranslate()` function tries to correct the possible geometrical problem(s) of the input `boundary` using `sf::st_make_valid()`. 
* Updated the `geofabrik_zones` database ([#270](https://github.com/ropensci/osmextract/issues/270)). 

### DOCUMENTATION FIXES
* Update description for `boundary` and `boundary_type` arguments.
* The main vignette and all examples save their files in `tempdir()` ([#247](https://github.com/ropensci/osmextract/issues/247)). 

# osmextract 0.4.1

Help files below `man/` have been re-generated, so that they give rise to valid HTML5 (#259). 

# osmextract 0.4.0 

### MAJOR CHANGES

* Import two new packages: [`httr`](https://cran.r-project.org/package=httr) and [`jsonlite`](https://cran.r-project.org/package=jsonlite) (#231, #232). 
* Improved the approach adopted to download files from the web. In particular, the functions `oe_download()` and `oe_search()` now take advantage of `httr` functionalities. They return informative messages in case of errors (#231, #232). 
* Vignettes and examples do not require internet connection. 

### BUG FIXES

* Fixed a bug in `oe_vectortranslate()` that occurred when reading `multilinestrings` or `other_relations` layers with one or more extra tags (#229). 
* Fixed a bug in `oe_get()`/`oe_read()` that could return a warning message when reading an existing GPKG file with a `query` argument. 

### MINOR CHANGES

* The duplicated fields in `extra_tags` are now removed before modifying the `osmconf.ini` file. Duplicated tags means something like `extra_tags = c("A", "A")` or even fields that are included by default (i.e. `extra_tags = "highway"` for the `lines` layer). See discussion in #229. 

# osmextract 0.3.1

### MAJOR CHANGES

* Added a new (but still experimental) function named `oe_get_network()` to import a road network used by a specific mode of transport. For the moment, we support the following modes of transport: cycling (default), walking, and driving. Check `?oe_get_network` for more details and examples (#218). 

### MINOR CHANGES

* The `layer` argument is now converted to lower case before checking if the required layer is admissible. 
* Adjusted the code behind `oe_get()` and `oe_vectortranslate()` for `sf` v1.0.2.
* Remove the call to `suppressMessages()` in `oe_match()` (#217).

### DOCUMENTATION FIXES

* Slightly changed the description of the package. 
* Added a `.Rd` file documenting the whole package. 
* Slightly changed the description of parameter `place`. 

# osmextract 0.3.0

### MAJOR CHANGES

* The `oe_get_keys()` function can be used to extract the values associated with all or some keys. We also defined an ad-hoc printing method and fixed several bugs. The examples were improved. Moreover, the function tries to match an input `zone` with one of the OSM extracts previously downloaded (#201 and #196). 
* If the parameter `place` represents an `sf`/`sfc`/`bbox` object with missing CRS, then `oe_match()` raises a warning message and sets `CRS = 4326`. This has relevant consequences on other functions (like `oe_get()`) that wrap `oe_match()`. 
* Starting from `sf` > 0.9.8, the function `oe_vectortranslate()` stops with an error when there is a problem in the argument `vectortranslate_options` and `quiet = FALSE` (instead of raising a warning or crashing the `R` session). See [here](https://github.com/r-spatial/sf/issues/1680) for more details. 
* The options `c("-f", "GPKG", "-overwrite", "-oo", "CONFIG_FILE=", path-to-config-file, "-lco", "GEOMETRY_NAME=geometry", layer)` are always appended at the end of `vectortranslate_options` argument unless the user explicitly sets different default parameters for the arguments `-f`, `-oo` and `-lco` (#200). We believe those are sensible defaults and can help users creating less verbose specifications for `ogr2ogr` utility. 
* We create two new arguments in `oe_vectortranslate()` (therefore also in `oe_get()` and `oe_read()`) named `boundary` and `boundary_type`. They can be used to create an ad-hoc spatial filter during the vectortranslate operations (and create even less verbose specifications in `vectortranslate_options` argument). See docs and introductory vignette for more details. 
* The argument `provider` was removed from `oe_match_pattern()` since the function automatically checks all available providers (#208). 

### BUG FIXES

* The parameter `force_vectortranslate` is checked before reading the layers of an existing `gpkg` file. If `force_vectortranslate` is `TRUE`, then `oe_vectortranslate()` doesn't check the existing layers. This is important for user that run `oe_vectortranslate()` after stopping the vectortranslate process.  
* The arguments `extra_tags` and `osmconf_ini` are not ignored when `vectortranslate_options` is not `NULL` (#182). 
* Fix the provider's data objects for `sf` v1.0 (#194). 

### MINOR IMPROVEMENTS

* The arguments passed to `oe_read()` via `...` are compared with the formals of `st_read.character`, `st_as_sf.data.frame`, and `read_sf`.  
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
