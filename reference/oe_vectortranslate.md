# Translate a .osm.pbf file into .gpkg format

This function is used to translate a `.osm.pbf` file into `.gpkg`
format. The conversion is performed using
[ogr2ogr](https://gdal.org/en/stable/programs/ogr2ogr.html) via the
`vectortranslate` utility in
[`sf::gdal_utils()`](https://r-spatial.github.io/sf/reference/gdal_utils.html)
. It was created following [the
suggestions](https://github.com/OSGeo/gdal/issues/2100#issuecomment-565707053)
of the maintainers of GDAL. See Details and Examples to understand the
basic usage, and check the introductory vignette for more complex
use-cases.

## Usage

``` r
oe_vectortranslate(
  file_path,
  layer = "lines",
  vectortranslate_options = NULL,
  osmconf_ini = NULL,
  extra_tags = NULL,
  force_vectortranslate = FALSE,
  never_skip_vectortranslate = FALSE,
  boundary = NULL,
  boundary_type = c("spat", "clipsrc"),
  quiet = FALSE
)
```

## Arguments

- file_path:

  Character string representing the path of the input `.pbf` or
  `.osm.pbf` file.

- layer:

  Which `layer` should be read in? Typically `points`, `lines` (the
  default), `multilinestrings`, `multipolygons` or `other_relations`. If
  you specify an ad-hoc query using the argument `query` (see
  introductory vignette and examples), then
  [`oe_get()`](https://docs.ropensci.org/osmextract/reference/oe_get.md)
  and
  [`oe_read()`](https://docs.ropensci.org/osmextract/reference/oe_read.md)
  will read the layer specified in the query and ignore `layer`
  argument. See also
  [\#122](https://github.com/ropensci/osmextract/issues/122).

- vectortranslate_options:

  Options passed to the
  [`sf::gdal_utils()`](https://r-spatial.github.io/sf/reference/gdal_utils.html)
  argument `options`. Set by default. Check details in the introductory
  vignette and the help page of `oe_vectortranslate()`.

- osmconf_ini:

  The configuration file. See documentation at
  [gdal.org](https://gdal.org/en/stable/drivers/vector/osm.html). Check
  details in the introductory vignette and the help page of
  `oe_vectortranslate()`. Set by default.

- extra_tags:

  Which additional columns, corresponding to OSM tags, should be in the
  resulting dataset? `NULL` by default. Check the introductory vignette
  and the help pages of `oe_vectortranslate()` and
  [`oe_get_keys()`](https://docs.ropensci.org/osmextract/reference/oe_get_keys.md).
  Ignored when `osmconf_ini` is not `NULL`.

- force_vectortranslate:

  Boolean. Force the original `.pbf` file to be translated into a
  `.gpkg` file, even if a `.gpkg` with the same name already exists?
  `FALSE` by default. If tags in `extra_tags` match data in previously
  translated `.gpkg` files no translation occurs (see
  [\#173](https://github.com/ropensci/osmextract/issues/173) for
  details). Check the introductory vignette and the help page of
  `oe_vectortranslate()`.

- never_skip_vectortranslate:

  Boolean. This is used in case the user passed its own `.ini` file or
  vectortranslate options (since, in those case, it's too difficult to
  determine if an existing `.gpkg` file was generated following the same
  options.)

- boundary:

  An `sf`/`sfc`/`bbox` object that will be used to create a spatial
  filter during the vectortranslate operations. If you are running
  [`oe_get()`](https://docs.ropensci.org/osmextract/reference/oe_get.md)
  and `place` is an `sf`/`sfc` polygon or a `bbox`, then it will be used
  as `boundary` if the latter is not specified. Set `boundary = NA` to
  override this behaviour and forcefully import the full extract.

- boundary_type:

  A character vector of length 1 specifying the type of spatial filter.
  The `spat` filter selects only those features that intersect a given
  area, while `clipsrc` also clips the geometries. Check the examples
  and also [here](https://gdal.org/en/stable/programs/ogr2ogr.html) for
  more details.

- quiet:

  Boolean. If `FALSE`, the function prints informative messages.
  Starting from `sf` version
  [0.9.6](https://r-spatial.github.io/sf/news/index.html#version-0-9-6-2020-09-13),
  if `quiet` is equal to `FALSE`, then vectortranslate operations will
  display a progress bar.

## Value

Character string representing the path of the `.gpkg` file.

## Details

The new `.gpkg` file is created in the same directory as the input
`.osm.pbf` file. The translation process is performed using the
`vectortranslate` utility in
[`sf::gdal_utils()`](https://r-spatial.github.io/sf/reference/gdal_utils.html).
This operation can be customized in several ways modifying the
parameters `layer`, `extra_tags`, `osmconf_ini`,
`vectortranslate_options`, `boundary` and `boundary_type`.

The `.osm.pbf` files processed by GDAL are usually categorized into 5
layers, named `points`, `lines`, `multilinestrings`, `multipolygons` and
`other_relations`. Check the first paragraphs
[here](https://gdal.org/en/stable/drivers/vector/osm.html) for more
details. This function can covert only one layer at a time, and the
parameter `layer` is used to specify which layer of the `.osm.pbf` file
should be converted. Several layers with different names can be stored
in the same `.gpkg` file. By default, the function will convert the
`lines` layer (which is the most common one according to our
experience).

The arguments `osmconf_ini` and `extra_tags` are used to modify how GDAL
reads and processes a `.osm.pbf` file. More precisely, several
operations that GDAL performs on the input `.osm.pbf` file are governed
by a `CONFIG` file. If `osmconf_ini` is equal to `NULL` (the default
value), then the function uses a standard `CONFIG` file provided by `sf`
or `GDAL`. Otherwise, it implements a fall-back based on an historical
config file available
[here](https://raw.githubusercontent.com/ropensci/osmextract/refs/heads/master/inst/osmconf.ini).
You can override the default `CONFIG` file in case you need more control
over the GDAL operations. Check the package introductory vignette for an
example.

The parameter `extra_tags` is used to determine which extra tags (i.e.
key/value pairs) should be added to the `.gpkg` file (other than the
default ones).

By default, the vectortranslate operations are skipped if the function
detects a file having the same path as the input file, `.gpkg`
extension, a layer with the same name as the parameter `layer` and all
`extra_tags`. In that case the function will simply return the path of
the `.gpkg` file. This behaviour can be overwritten setting
`force_vectortranslate = TRUE`. The vectortranslate operations are never
skipped if `osmconf_ini`, `vectortranslate_options`, `boundary` or
`boundary_type` arguments are not `NULL`.

The parameter `vectortranslate_options` is used to control the options
that are passed to `ogr2ogr` via
[`sf::gdal_utils()`](https://r-spatial.github.io/sf/reference/gdal_utils.html)
when converting between `.osm.pbf` and `.gpkg` formats. `ogr2ogr` can
perform various operations during the conversion process, such as
spatial filters or SQL queries. These operations can be tuned using the
`vectortranslate_options` argument. If `NULL` (the default value), then
`vectortranslate_options` is set equal to

`c("-f", "GPKG", "-overwrite", "-oo", paste0("CONFIG_FILE=", osmconf_ini), "-lco", "GEOMETRY_NAME=geometry", layer)`.

Explanation:

- `"-f", "GPKG"` says that the output format is `GPKG`;

- `"-overwrite` is used to delete an existing layer and recreate it
  empty;

- `"-oo", paste0("CONFIG_FILE=", osmconf_ini)` is used to set the [Open
  Options](https://gdal.org/en/stable/drivers/vector/osm.html#open-options)
  for the `.osm.pbf` file and change the `CONFIG` file (in case the user
  asks for any extra tag or a totally different CONFIG file);

- `"-lco", "GEOMETRY_NAME=geometry"` is used to change the [layer
  creation
  options](https://gdal.org/en/stable/drivers/vector/gpkg.html#layer-creation-options)
  for the `.gpkg` file and modify the name of the geometry column;

- `layer` indicates which layer should be converted.

If `vectortranslate_options` is not `NULL`, then the options
`c("-f", "GPKG", "-overwrite", "-oo", "CONFIG_FILE=", path-to-config-file, "-lco", "GEOMETRY_NAME=geometry", layer)`
are always appended unless the user explicitly sets different default
parameters for the arguments `-f`, `-oo`, `-lco`, and `layer`.

The arguments `boundary` and `boundary_type` can be used to set up a
spatial filter during the vectortranslate operations (and speed up the
process) using an `sf` or `sfc` object (`POLYGON` or `MULTIPOLYGON`).
The default arguments create a rectangular spatial filter which selects
all features that intersect the area. Setting
`boundary_type = "clipsrc"` clips the geometries. In both cases, the
appropriate options are automatically added to the
`vectortranslate_options` (unless a user explicitly sets different
default options). Check Examples in
[`oe_get()`](https://docs.ropensci.org/osmextract/reference/oe_get.md)
and the introductory vignette.

See also the help page of
[`sf::gdal_utils()`](https://r-spatial.github.io/sf/reference/gdal_utils.html)
and [ogr2ogr](https://gdal.org/en/stable/programs/ogr2ogr.html) for more
examples and extensive documentation on all available options that can
be tuned during the vectortranslate process.

## See also

[`oe_get_keys()`](https://docs.ropensci.org/osmextract/reference/oe_get_keys.md)

## Examples

``` r
# First we need to match an input zone with a .osm.pbf file
(its_match = oe_match("ITS Leeds"))
#> The input place was matched with: ITS Leeds
#> $url
#> [1] "https://github.com/ropensci/osmextract/raw/master/inst/its-example.osm.pbf"
#> 
#> $file_size
#> [1] 40792
#> 

# Copy ITS file to tempdir so that the examples do not require internet
# connection. You can skip the next 3 lines (and start directly with
# oe_download()) when running the examples locally.

file.copy(
  from = system.file("its-example.osm.pbf", package = "osmextract"),
  to = file.path(tempdir(), "test_its-example.osm.pbf"),
  overwrite = TRUE
)
#> [1] TRUE

# The we can download the .osm.pbf file (if it was not already downloaded)
its_pbf = oe_download(
  file_url = its_match$url,
  file_size = its_match$file_size,
  download_directory = tempdir(),
  provider = "test"
)
#> The chosen file was already detected in the download directory. Skip downloading.

# Check that the file was downloaded
list.files(tempdir(), pattern = "pbf|gpkg")
#> [1] "test_its-example.osm.pbf"

# Convert to gpkg format
its_gpkg = oe_vectortranslate(its_pbf)
#> Starting with the vectortranslate operations on the input file!
#> 0...10...20...30...40...50...60...70...80...90...100 - done.
#> Finished the vectortranslate operations on the input file!

# Now there is an extra .gpkg file
list.files(tempdir(), pattern = "pbf|gpkg")
#> [1] "test_its-example.gpkg"    "test_its-example.osm.pbf"

# Check the layers of the .gpkg file
sf::st_layers(its_gpkg, do_count = TRUE)
#> Driver: GPKG 
#> Available layers:
#>   layer_name geometry_type features fields crs_name
#> 1      lines   Line String      189     10   WGS 84

# Add points layer
its_gpkg = oe_vectortranslate(its_pbf, layer = "points")
#> Adding a new layer to the .gpkg file.
#> Starting with the vectortranslate operations on the input file!
#> 0...10...20...30...40...50...60...70...80...90...100 - done.
#> Finished the vectortranslate operations on the input file!
sf::st_layers(its_gpkg, do_count = TRUE)
#> Driver: GPKG 
#> Available layers:
#>   layer_name geometry_type features fields crs_name
#> 1      lines   Line String      189     10   WGS 84
#> 2     points         Point      186     10   WGS 84

# Add extra tags to the lines layer
names(sf::st_read(its_gpkg, layer = "lines", quiet = TRUE))
#>  [1] "osm_id"     "name"       "highway"    "waterway"   "aerialway" 
#>  [6] "barrier"    "man_made"   "railway"    "z_order"    "other_tags"
#> [11] "geometry"  
its_gpkg = oe_vectortranslate(
  its_pbf,
  extra_tags = c("oneway", "maxspeed")
)
#> Starting with the vectortranslate operations on the input file!
#> 0...10...20...30...40...50...60...70...80...90...100 - done.
#> Finished the vectortranslate operations on the input file!
names(sf::st_read(its_gpkg, layer = "lines", quiet = TRUE))
#>  [1] "osm_id"     "name"       "highway"    "waterway"   "aerialway" 
#>  [6] "barrier"    "man_made"   "railway"    "oneway"     "maxspeed"  
#> [11] "z_order"    "other_tags" "geometry"  

# Adjust vectortranslate options and convert only 10 features
# for the lines layer
oe_vectortranslate(
  its_pbf,
  vectortranslate_options = c("-limit", 10)
)
#> Starting with the vectortranslate operations on the input file!
#> 0...10...20...30...40...50...60...70...80...90...100 - done.
#> Finished the vectortranslate operations on the input file!
#> [1] "/tmp/Rtmp1TKvNm/test_its-example.gpkg"
sf::st_layers(its_gpkg, do_count = TRUE)
#> Driver: GPKG 
#> Available layers:
#>   layer_name geometry_type features fields crs_name
#> 1     points         Point      186     10   WGS 84
#> 2      lines   Line String       10     10   WGS 84

# Remove .pbf and .gpkg files in tempdir
oe_clean(tempdir())
```
