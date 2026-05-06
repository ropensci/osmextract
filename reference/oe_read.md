# Read a .pbf or .gpkg object from file or url

This function is used to read a `.pbf` or `.gpkg` object from file or
URL. It is a wrapper around [`oe_download()`](oe_download.md),
[`oe_vectortranslate()`](oe_vectortranslate.md), and
[`sf::st_read()`](https://r-spatial.github.io/sf/reference/st_read.html),
creating an easy way to download, convert, and read a `.pbf` or `.gpkg`
file. Check the introductory vignette and the help pages of the wrapped
function for more details.

## Usage

``` r
oe_read(
  file_path,
  layer = "lines",
  ...,
  provider = NULL,
  download_directory = oe_download_directory(),
  file_size = NULL,
  force_download = FALSE,
  max_file_size = 5e+08,
  download_only = FALSE,
  skip_vectortranslate = FALSE,
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

  A URL or the path to a `.pbf` or `.gpkg` file. If a URL, then it must
  be specified using HTTP/HTTPS protocol.

- layer:

  Which `layer` should be read in? Typically `points`, `lines` (the
  default), `multilinestrings`, `multipolygons` or `other_relations`. If
  you specify an ad-hoc query using the argument `query` (see
  introductory vignette and examples), then [`oe_get()`](oe_get.md) and
  `oe_read()` will read the layer specified in the query and ignore
  `layer` argument. See also
  [\#122](https://github.com/ropensci/osmextract/issues/122).

- ...:

  (Named) arguments that will be passed to
  [`sf::st_read()`](https://r-spatial.github.io/sf/reference/st_read.html),
  like `query`, `wkt_filter` or `stringsAsFactors`. Check the
  introductory vignette to understand how to create your own (SQL-like)
  queries.

- provider:

  Which provider should be used to download the data? Available
  providers can be browsed with [`oe_providers()`](oe_providers.md). For
  [`oe_get()`](oe_get.md) and [`oe_match()`](oe_match.md), if `place` is
  equal to `ITS Leeds`, then `provider` is internally set equal to
  `"test"`. This is just for simple examples and internal tests.

- download_directory:

  Directory to store the file containing OSM data?.

- file_size:

  How big is the file? Optional. `NA` by default. If it's bigger than
  `max_file_size` and the function is run in interactive mode, then an
  interactive menu is displayed, asking for permission to download the
  file.

- force_download:

  Should the `.osm.pbf` file be updated even if it has already been
  downloaded? `FALSE` by default. This parameter is used to update old
  `.osm.pbf` files.

- max_file_size:

  The maximum file size to download without asking in interactive mode.
  Default: `5e+8`, half a gigabyte.

- download_only:

  Boolean. If `TRUE`, then the function only returns the path where the
  matched file is stored, instead of reading it. `FALSE` by default.

- skip_vectortranslate:

  Boolean. If `TRUE`, then the function skips all vectortranslate
  operations and it reads (or simply returns the path) of the `.osm.pbf`
  file. `FALSE` by default.

- vectortranslate_options:

  Options passed to the
  [`sf::gdal_utils()`](https://r-spatial.github.io/sf/reference/gdal_utils.html)
  argument `options`. Set by default. Check details in the introductory
  vignette and the help page of
  [`oe_vectortranslate()`](oe_vectortranslate.md).

- osmconf_ini:

  The configuration file. See documentation at
  [gdal.org](https://gdal.org/en/stable/drivers/vector/osm.html). Check
  details in the introductory vignette and the help page of
  [`oe_vectortranslate()`](oe_vectortranslate.md). Set by default.

- extra_tags:

  Which additional columns, corresponding to OSM tags, should be in the
  resulting dataset? `NULL` by default. Check the introductory vignette
  and the help pages of [`oe_vectortranslate()`](oe_vectortranslate.md)
  and [`oe_get_keys()`](oe_get_keys.md). Ignored when `osmconf_ini` is
  not `NULL`.

- force_vectortranslate:

  Boolean. Force the original `.pbf` file to be translated into a
  `.gpkg` file, even if a `.gpkg` with the same name already exists?
  `FALSE` by default. If tags in `extra_tags` match data in previously
  translated `.gpkg` files no translation occurs (see
  [\#173](https://github.com/ropensci/osmextract/issues/173) for
  details). Check the introductory vignette and the help page of
  [`oe_vectortranslate()`](oe_vectortranslate.md).

- never_skip_vectortranslate:

  Boolean. This is used in case the user passed its own `.ini` file or
  vectortranslate options (since, in those case, it's too difficult to
  determine if an existing `.gpkg` file was generated following the same
  options.)

- boundary:

  An `sf`/`sfc`/`bbox` object that will be used to create a spatial
  filter during the vectortranslate operations. If you are running
  [`oe_get()`](oe_get.md) and `place` is an `sf`/`sfc` polygon or a
  `bbox`, then it will be used as `boundary` if the latter is not
  specified. Set `boundary = NA` to override this behaviour and
  forcefully import the full extract.

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

An `sf` object or, when `download_only` argument equals `TRUE`, a
character vector.

## Details

The arguments `provider`, `download_directory`, `file_size`,
`force_download`, and `max_file_size` are ignored if `file_path` points
to an existing `.pbf` or `.gpkg` file.

Please note that you cannot add any field to an existing `.gpkg` file
using the argument `extra_tags` without rerunning the vectortranslate
process on the corresponding `.pbf` file. On the other hand, you can
extract some of the tags in `other_tags` field as new columns. See
examples and [`oe_get_keys()`](oe_get_keys.md) for more details.

## Examples

``` r
# Read an existing .pbf file. First we need to copy a .pbf file into a
# temporary directory
its_pbf = file.path(tempdir(), "test_its-example.osm.pbf")
file.copy(
  from = system.file("its-example.osm.pbf", package = "osmextract"),
  to = its_pbf
)
#> [1] TRUE
oe_read(its_pbf)
#> Starting with the vectortranslate operations on the input file!
#> 0...10...20...30...40...50...60...70...80...90...100 - done.
#> Finished the vectortranslate operations on the input file!
#> Reading layer `lines' from data source `/tmp/RtmpQk2KqP/test_its-example.gpkg' using driver `GPKG'
#> Simple feature collection with 189 features and 10 fields
#> Geometry type: LINESTRING
#> Dimension:     XY
#> Bounding box:  xmin: -1.562458 ymin: 53.80471 xmax: -1.548076 ymax: 53.81105
#> Geodetic CRS:  WGS 84

# Read a new layer
oe_read(its_pbf, layer = "points")
#> Adding a new layer to the .gpkg file.
#> Starting with the vectortranslate operations on the input file!
#> 0...10...20...30...40...50...60...70...80...90...100 - done.
#> Finished the vectortranslate operations on the input file!
#> Reading layer `points' from data source `/tmp/RtmpQk2KqP/test_its-example.gpkg' using driver `GPKG'
#> Simple feature collection with 186 features and 10 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -1.568766 ymin: 53.80569 xmax: -1.549451 ymax: 53.81136
#> Geodetic CRS:  WGS 84

# The following example shows how to add new tags
names(oe_read(its_pbf, extra_tags = c("oneway", "ref"), quiet = TRUE))
#>  [1] "osm_id"     "name"       "highway"    "waterway"   "aerialway" 
#>  [6] "barrier"    "man_made"   "railway"    "oneway"     "ref"       
#> [11] "z_order"    "other_tags" "geometry"  

# Read an existing .gpkg file. This file was created internally by oe_read().
its_gpkg = file.path(tempdir(), "test_its-example.gpkg")
oe_read(its_gpkg)
#> Reading layer `lines' from data source `/tmp/RtmpQk2KqP/test_its-example.gpkg' using driver `GPKG'
#> Simple feature collection with 189 features and 12 fields
#> Geometry type: LINESTRING
#> Dimension:     XY
#> Bounding box:  xmin: -1.562458 ymin: 53.80471 xmax: -1.548076 ymax: 53.81105
#> Geodetic CRS:  WGS 84

# You cannot add any new layer to an existing .gpkg file but you can extract
# some of the tags in other_tags. Check oe_get_keys() for more details.
names(oe_read(its_gpkg, extra_tags = c("maxspeed"))) # doesn't work
#> Reading layer `lines' from data source `/tmp/RtmpQk2KqP/test_its-example.gpkg' using driver `GPKG'
#> Simple feature collection with 189 features and 12 fields
#> Geometry type: LINESTRING
#> Dimension:     XY
#> Bounding box:  xmin: -1.562458 ymin: 53.80471 xmax: -1.548076 ymax: 53.81105
#> Geodetic CRS:  WGS 84
#>  [1] "osm_id"     "name"       "highway"    "waterway"   "aerialway" 
#>  [6] "barrier"    "man_made"   "railway"    "oneway"     "ref"       
#> [11] "z_order"    "other_tags" "geometry"  
# Instead, use the query argument
names(oe_read(
  its_gpkg,
  quiet = TRUE,
  query =
  "SELECT *,
  hstore_get_value(other_tags, 'maxspeed') AS maxspeed
  FROM lines
  "
))
#>  [1] "osm_id"     "name"       "highway"    "waterway"   "aerialway" 
#>  [6] "barrier"    "man_made"   "railway"    "oneway"     "ref"       
#> [11] "z_order"    "other_tags" "maxspeed"   "geometry"  

# Read from a URL
my_url = "https://github.com/ropensci/osmextract/raw/master/inst/its-example.osm.pbf"
# Please note that if you read from a URL which is not linked to one of the
# supported providers, you need to specify the provider parameter:
if (FALSE) { # \dontrun{
oe_read(my_url, provider = "test", quiet = FALSE)} # }

# Remove .pbf and .gpkg files in tempdir
oe_clean(tempdir())
```
