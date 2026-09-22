# Read a .pbf or .gpkg object from file or url

This function is used to read a `.pbf` or `.gpkg` object from file or
URL. It is a wrapper around
[`oe_download()`](https://docs.ropensci.org/osmextract/reference/oe_download.md),
[`oe_vectortranslate()`](https://docs.ropensci.org/osmextract/reference/oe_vectortranslate.md),
and
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
  introductory vignette and examples), then
  [`oe_get()`](https://docs.ropensci.org/osmextract/reference/oe_get.md)
  and `oe_read()` will read the layer specified in the query and ignore
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
  providers can be browsed with
  [`oe_providers()`](https://docs.ropensci.org/osmextract/reference/oe_providers.md).
  For
  [`oe_get()`](https://docs.ropensci.org/osmextract/reference/oe_get.md)
  and
  [`oe_match()`](https://docs.ropensci.org/osmextract/reference/oe_match.md),
  if `place` is equal to `ITS Leeds`, then `provider` is internally set
  equal to `"test"`. This is just for simple examples and internal
  tests.

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
  [`oe_vectortranslate()`](https://docs.ropensci.org/osmextract/reference/oe_vectortranslate.md).

- osmconf_ini:

  The configuration file. See documentation at
  [gdal.org](https://gdal.org/en/stable/drivers/vector/osm.html). Check
  details in the introductory vignette and the help page of
  [`oe_vectortranslate()`](https://docs.ropensci.org/osmextract/reference/oe_vectortranslate.md).
  Set by default.

- extra_tags:

  Which additional columns, corresponding to OSM tags, should be in the
  resulting dataset? `NULL` by default. Check the introductory vignette
  and the help pages of
  [`oe_vectortranslate()`](https://docs.ropensci.org/osmextract/reference/oe_vectortranslate.md)
  and
  [`oe_get_keys()`](https://docs.ropensci.org/osmextract/reference/oe_get_keys.md).
  Ignored when `osmconf_ini` is not `NULL`.

- force_vectortranslate:

  Boolean. Force the original `.pbf` file to be translated into a
  `.gpkg` file, even if a `.gpkg` with the same name already exists?
  `FALSE` by default. If tags in `extra_tags` match data in previously
  translated `.gpkg` files no translation occurs (see
  [\#173](https://github.com/ropensci/osmextract/issues/173) for
  details). Check the introductory vignette and the help page of
  [`oe_vectortranslate()`](https://docs.ropensci.org/osmextract/reference/oe_vectortranslate.md).

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
examples and
[`oe_get_keys()`](https://docs.ropensci.org/osmextract/reference/oe_get_keys.md)
for more details.

Starting from version 0.7, the function forcefully sets a precision
equal to 1e7 on the returned `sf` object, following the indications
reported in the [OSM wiki](https://wiki.openstreetmap.org/wiki/Node)
that coordinates are reported using a precision of 7 decimal places in
latitude and longitude. See also
[`?sf::st_coordinates`](https://r-spatial.github.io/sf/reference/st_coordinates.html).

## Examples

``` r
# Read an existing .pbf file. First we need to copy a .pbf file into a
# temporary directory
its_pbf = file.path(tempdir(), "test_its-example.osm.pbf")
file.copy(
  from = system.file("its-example.osm.pbf", package = "osmextract"),
  to = its_pbf
)
#> [1] FALSE
oe_read(its_pbf)
#> The corresponding gpkg file was already detected. Skip vectortranslate operations.
#> Reading layer `lines' from data source `/tmp/RtmpdO4lJc/test_its-example.gpkg' using driver `GPKG'
#> Simple feature collection with 93 features and 15 fields
#> Geometry type: LINESTRING
#> Dimension:     XY
#> Bounding box:  xmin: -1.562458 ymin: 53.80471 xmax: -1.548076 ymax: 53.81105
#> Geodetic CRS:  WGS 84
#> Simple feature collection with 93 features and 15 fields
#> Geometry type: LINESTRING
#> Dimension:     XY
#> Bounding box:  xmin: -1.562458 ymin: 53.80471 xmax: -1.548076 ymax: 53.81105
#> Geodetic CRS:  WGS 84
#> Precision:     1e+07 
#> First 10 features:
#>     osm_id                  name      highway waterway aerialway barrier
#> 1  6277600        Cavendish Road      service     <NA>      <NA>    <NA>
#> 2  6277601        Cavendish Road  residential     <NA>      <NA>    <NA>
#> 3  6295680         Blenheim Walk        trunk     <NA>      <NA>    <NA>
#> 4  6962440         Cemetery Road      service     <NA>      <NA>    <NA>
#> 5  6962444                  <NA>      service     <NA>      <NA>    <NA>
#> 6  6962455                  <NA>      service     <NA>      <NA>    <NA>
#> 7  6966713 Back Blenheim Terrace unclassified     <NA>      <NA>    <NA>
#> 8  6966716 Back Woodstock Street unclassified     <NA>      <NA>    <NA>
#> 9  6966718   Marlborough Gardens  residential     <NA>      <NA>    <NA>
#> 10 6966720     Marlborough Grove  residential     <NA>      <NA>    <NA>
#>    man_made railway     access       service oneway junction motor_vehicle
#> 1      <NA>    <NA> permissive          <NA>    yes     <NA>          <NA>
#> 2      <NA>    <NA>       <NA>          <NA>    yes     <NA>          <NA>
#> 3      <NA>    <NA>       <NA>          <NA>    yes     <NA>          <NA>
#> 4      <NA>    <NA>       <NA>          <NA>   <NA>     <NA>          <NA>
#> 5      <NA>    <NA>       <NA> parking_aisle   <NA>     <NA>          <NA>
#> 6      <NA>    <NA>       <NA>          <NA>   <NA>     <NA>          <NA>
#> 7      <NA>    <NA>        yes          <NA>   <NA>     <NA>          <NA>
#> 8      <NA>    <NA>       <NA>          <NA>   <NA>     <NA>          <NA>
#> 9      <NA>    <NA>       <NA>          <NA>   <NA>     <NA>          <NA>
#> 10     <NA>    <NA>       <NA>          <NA>   <NA>     <NA>          <NA>
#>    z_order
#> 1        0
#> 2        3
#> 3        8
#> 4        0
#> 5        0
#> 6        0
#> 7        3
#> 8        3
#> 9        3
#> 10       3
#>                                                                                                        other_tags
#> 1                                                                                                    "lanes"=>"1"
#> 2                                                                                                    "lanes"=>"1"
#> 3  "lanes"=>"2","lit"=>"yes","maxspeed"=>"30 mph","ref"=>"A660","turn:lanes"=>"left;through|through;slight_right"
#> 4                                                                                                            <NA>
#> 5                                                                                                            <NA>
#> 6                                                                                                            <NA>
#> 7                                                                                            "surface"=>"asphalt"
#> 8                                                                                            "surface"=>"asphalt"
#> 9                                                                               "lit"=>"yes","surface"=>"asphalt"
#> 10                                                                              "lit"=>"yes","surface"=>"asphalt"
#>                          geometry
#> 1  LINESTRING (-1.552587 53.80...
#> 2  LINESTRING (-1.551771 53.80...
#> 3  LINESTRING (-1.552894 53.80...
#> 4  LINESTRING (-1.558149 53.80...
#> 5  LINESTRING (-1.553665 53.80...
#> 6  LINESTRING (-1.557198 53.80...
#> 7  LINESTRING (-1.552227 53.80...
#> 8  LINESTRING (-1.552008 53.80...
#> 9  LINESTRING (-1.551731 53.80...
#> 10 LINESTRING (-1.551187 53.80...

# Read a new layer
oe_read(its_pbf, layer = "points")
#> Adding a new layer to the .gpkg file.
#> Starting with the vectortranslate operations on the input file!
#> 0...10...20...30...40...50...60...70...80...90...100 - done.
#> Finished the vectortranslate operations on the input file!
#> Reading layer `points' from data source `/tmp/RtmpdO4lJc/test_its-example.gpkg' using driver `GPKG'
#> Simple feature collection with 186 features and 10 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -1.568766 ymin: 53.80569 xmax: -1.549451 ymax: 53.81136
#> Geodetic CRS:  WGS 84
#> Simple feature collection with 186 features and 10 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -1.568766 ymin: 53.80569 xmax: -1.549451 ymax: 53.81136
#> Geodetic CRS:  WGS 84
#> Precision:     1e+07 
#> First 10 features:
#>      osm_id                         name barrier         highway      ref
#> 1  21069418                         <NA>    <NA> traffic_signals     <NA>
#> 2  21093230                         <NA>    <NA> mini_roundabout     <NA>
#> 3  26653419 Statue of Duke of Wellington    <NA>            <NA>     <NA>
#> 4  31004252                         <NA>    <NA> traffic_signals     <NA>
#> 5  31004259                         <NA>    <NA> traffic_signals     <NA>
#> 6  31004270                         <NA>    <NA>        crossing     <NA>
#> 7  31004287                         <NA>    <NA> traffic_signals     <NA>
#> 8  52905112                         <NA>    <NA>            <NA>   LS2 54
#> 9  52905119                         <NA>    <NA>            <NA>     <NA>
#> 10 52905122       Leeds University Steps    <NA>        bus_stop 45011386
#>    address is_in place man_made
#> 1     <NA>  <NA>  <NA>     <NA>
#> 2     <NA>  <NA>  <NA>     <NA>
#> 3     <NA>  <NA>  <NA>     <NA>
#> 4     <NA>  <NA>  <NA>     <NA>
#> 5     <NA>  <NA>  <NA>     <NA>
#> 6     <NA>  <NA>  <NA>     <NA>
#> 7     <NA>  <NA>  <NA>     <NA>
#> 8     <NA>  <NA>  <NA>     <NA>
#> 9     <NA>  <NA>  <NA>     <NA>
#> 10    <NA>  <NA>  <NA>     <NA>
#>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        other_tags
#> 1                                                                                                                                                                                                                                                                                                                                                                                                                                                         "crossing"=>"traffic_signals","crossing_ref"=>"pelican"
#> 2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            <NA>
#> 3                                                                                                                                                                                                                                                                                                                                                                                       "historic"=>"memorial","tourism"=>"artwork","url"=>"http://www.leodis.net/display.aspx?resourceIdentifier=2008118_165852"
#> 4                                                                                                                                                                                                                                                                                                                                                                                                                  "crossing"=>"traffic_signals","crossing_ref"=>"toucan","kerb"=>"flush","tactile_paving"=>"yes"
#> 5                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            <NA>
#> 6                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           "crossing"=>"pelican"
#> 7                                                                                                                                                                                                                                                                                                                                                                                                                                                         "crossing"=>"traffic_signals","crossing_ref"=>"pelican"
#> 8                                                                                                                                                                                                                                                                                                                                                                                                                                         "amenity"=>"post_box","operator"=>"Royal Mail","post_box:type"=>"meter"
#> 9                                                                                                                                                                                                                                                                                                                                                                                                                                    "amenity"=>"telephone","booth"=>"KXPlus","covered"=>"booth","operator"=>"BT"
#> 10 "bus"=>"yes","local_ref"=>"45011386","naptan:AtcoCode"=>"450011386","naptan:Bearing"=>"N","naptan:CommonName"=>"Leeds University","naptan:Crossing"=>"Back Blenheim Terrace","naptan:Indicator"=>"Stop 45011386","naptan:Landmark"=>"Leeds University","naptan:Notes"=>"New TF shelter and 3P fitted awaiting survey","naptan:PlusbusZoneRef"=>"LEEDS","naptan:ShortCommonName"=>"Leeds University","naptan:Street"=>"Woodhouse Lane","naptan:verified"=>"yes","public_transport"=>"platform","shelter"=>"yes"
#>                      geometry
#> 1   POINT (-1.552508 53.8086)
#> 2   POINT (-1.56583 53.81002)
#> 3  POINT (-1.559813 53.80819)
#> 4   POINT (-1.56048 53.80638)
#> 5  POINT (-1.559558 53.80796)
#> 6  POINT (-1.559285 53.80795)
#> 7  POINT (-1.551964 53.80751)
#> 8   POINT (-1.55062 53.80642)
#> 9  POINT (-1.552372 53.80799)
#> 10 POINT (-1.552314 53.80809)

# The following example shows how to add new tags
names(oe_read(its_pbf, extra_tags = c("oneway", "ref"), quiet = TRUE))
#>  [1] "osm_id"     "name"       "highway"    "waterway"   "aerialway" 
#>  [6] "barrier"    "man_made"   "railway"    "oneway"     "ref"       
#> [11] "z_order"    "other_tags" "geometry"  

# Read an existing .gpkg file. This file was created internally by oe_read().
its_gpkg = file.path(tempdir(), "test_its-example.gpkg")
oe_read(its_gpkg)
#> Reading layer `lines' from data source `/tmp/RtmpdO4lJc/test_its-example.gpkg' using driver `GPKG'
#> Simple feature collection with 189 features and 12 fields
#> Geometry type: LINESTRING
#> Dimension:     XY
#> Bounding box:  xmin: -1.562458 ymin: 53.80471 xmax: -1.548076 ymax: 53.81105
#> Geodetic CRS:  WGS 84
#> Simple feature collection with 189 features and 12 fields
#> Geometry type: LINESTRING
#> Dimension:     XY
#> Bounding box:  xmin: -1.562458 ymin: 53.80471 xmax: -1.548076 ymax: 53.81105
#> Geodetic CRS:  WGS 84
#> Precision:     1e+07 
#> First 10 features:
#>     osm_id           name     highway waterway aerialway barrier man_made
#> 1  4371081           <NA>     footway     <NA>      <NA>    <NA>     <NA>
#> 2  4371084           <NA>    cycleway     <NA>      <NA>    <NA>     <NA>
#> 3  4419868    Cannon Walk     footway     <NA>      <NA>    <NA>     <NA>
#> 4  6277600 Cavendish Road     service     <NA>      <NA>    <NA>     <NA>
#> 5  6277601 Cavendish Road residential     <NA>      <NA>    <NA>     <NA>
#> 6  6295680  Blenheim Walk       trunk     <NA>      <NA>    <NA>     <NA>
#> 7  6962430           <NA>     footway     <NA>      <NA>    <NA>     <NA>
#> 8  6962433           <NA>     footway     <NA>      <NA>    <NA>     <NA>
#> 9  6962435           <NA>     footway     <NA>      <NA>    <NA>     <NA>
#> 10 6962440  Cemetery Road     service     <NA>      <NA>    <NA>     <NA>
#>    railway oneway  ref z_order
#> 1     <NA>   <NA> <NA>       0
#> 2     <NA>   <NA> <NA>       0
#> 3     <NA>   <NA> <NA>       0
#> 4     <NA>    yes <NA>       0
#> 5     <NA>    yes <NA>       3
#> 6     <NA>    yes A660       8
#> 7     <NA>   <NA> <NA>       0
#> 8     <NA>   <NA> <NA>       0
#> 9     <NA>   <NA> <NA>       0
#> 10    <NA>   <NA> <NA>       0
#>                                                                                          other_tags
#> 1                                                                                              <NA>
#> 2                                                      "bicycle"=>"designated","foot"=>"designated"
#> 3                                 "website"=>"http://woodhousemooronline.com/the-cannon-destroyer/"
#> 4                                                               "access"=>"permissive","lanes"=>"1"
#> 5                                                                                      "lanes"=>"1"
#> 6  "lanes"=>"2","lit"=>"yes","maxspeed"=>"30 mph","turn:lanes"=>"left;through|through;slight_right"
#> 7                                                                                              <NA>
#> 8                                                                                              <NA>
#> 9                                                                                              <NA>
#> 10                                                                                             <NA>
#>                          geometry
#> 1  LINESTRING (-1.560083 53.80...
#> 2  LINESTRING (-1.559709 53.80...
#> 3  LINESTRING (-1.5609 53.8085...
#> 4  LINESTRING (-1.552587 53.80...
#> 5  LINESTRING (-1.551771 53.80...
#> 6  LINESTRING (-1.552894 53.80...
#> 7  LINESTRING (-1.554698 53.80...
#> 8  LINESTRING (-1.557451 53.80...
#> 9  LINESTRING (-1.556508 53.80...
#> 10 LINESTRING (-1.558149 53.80...

# You cannot add any new layer to an existing .gpkg file but you can extract
# some of the tags in other_tags. Check oe_get_keys() for more details.
names(oe_read(its_gpkg, extra_tags = c("maxspeed"))) # doesn't work
#> Reading layer `lines' from data source `/tmp/RtmpdO4lJc/test_its-example.gpkg' using driver `GPKG'
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
