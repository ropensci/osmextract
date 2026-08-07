# Get the path of .pbf and .gpkg files associated with an input OSM extract

This function takes a `place` name and returns the path of
`.pbf`/`.gpkg` files associated with it.

## Usage

``` r
oe_find(
  place,
  provider = "geofabrik",
  download_directory = oe_download_directory(),
  download_if_missing = FALSE,
  return_pbf = TRUE,
  return_gpkg = TRUE,
  quiet = FALSE,
  ...
)
```

## Arguments

- place:

  Description of the geographical area that should be matched with a
  `.osm.pbf` file. Can be either a length-1 character vector, an
  `sf`/`sfc`/`bbox` object with any CRS, or a numeric vector of
  coordinates with length 2. In the last case, it is assumed that the
  EPSG code is 4326 specified as c(LON, LAT), while you can use any CRS
  with `sf`/`sfc`/`bbox` objects. See Details and Examples in
  [`oe_match()`](https://docs.ropensci.org/osmextract/reference/oe_match.md).

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

  Directory where the function looks for matches.

- download_if_missing:

  Should we attempt to download the matched file if it cannot be found?
  `FALSE` by default.

- return_pbf:

  Logical of length 1. If `TRUE`, the function returns the path of the
  .osm.pbf file that matches the input `place`.

- return_gpkg:

  Logical of length 1. If `TRUE`, the function returns the path of the
  .gpkg file that matches the input `place`.

- quiet:

  Boolean. If `FALSE`, the function prints informative messages.
  Starting from `sf` version
  [0.9.6](https://r-spatial.github.io/sf/news/index.html#version-0-9-6-2020-09-13),
  if `quiet` is equal to `FALSE`, then vectortranslate operations will
  display a progress bar.

- ...:

  Extra arguments that are passed to
  [`oe_match()`](https://docs.ropensci.org/osmextract/reference/oe_match.md)
  and
  [`oe_get()`](https://docs.ropensci.org/osmextract/reference/oe_get.md).
  Please note that you cannot pass the argument `download_only`.

## Value

A character vector of length one (or two) representing the path(s) of
the `.pbf`/`.gpkg` files associated with the input `place`. The files
are sorted in alphabetical order, which implies that if both formats are
present in the `download_directory`, then the `.gpkg` file should be
returned first.

## Details

The matching between the existing files (saved in the directory
specified by `download_directory` parameter) and the input `place` is
performed using
[`list.files()`](https://rdrr.io/r/base/list.files.html), setting the
`pattern` argument equal to the basename of the URL associated to the
input `place`. For example, if you specify `place = "Isle of Wight"`,
then your input is matched (via
[`oe_match()`](https://docs.ropensci.org/osmextract/reference/oe_match.md))
with the URL of Isle of Wight. Finally, the files are selected using a
`pattern` equal to the basename of that URL.

If there is no file in the `download_directory` that can be matched with
the basename of the URL and `download_if_missing` is `TRUE`, then the
function tries to download it (`geofabrik` is the default provider) and
returns the path. Otherwise it stops with an error.

By default, this function returns the path of both `.osm.pbf` and
`.gpkg` files associated with the input place (if any). You can exclude
one of the two formats using the arguments `return_pbf` or `return_gpkg`
to `FALSE`.

## Examples

``` r
# Copy the ITS file to tempdir() to make sure that the examples do not
# require internet connection. You can skip the next 4 lines (and start
# directly with oe_get_keys) when running the examples locally.
res = file.copy(
  from = system.file("its-example.osm.pbf", package = "osmextract"),
  to = file.path(tempdir(), "test_its-example.osm.pbf"),
  overwrite = TRUE
)
res = oe_get("ITS Leeds", quiet = TRUE, download_directory = tempdir())
oe_find("ITS Leeds", provider = "test", download_directory = tempdir())
#> The input place was matched with: ITS Leeds
#> [1] "/tmp/RtmpBx9Hdj/test_its-example.gpkg"   
#> [2] "/tmp/RtmpBx9Hdj/test_its-example.osm.pbf"
oe_find(
  "ITS Leeds", provider = "test",
  download_directory = tempdir(), return_gpkg = FALSE
)
#> The input place was matched with: ITS Leeds
#> [1] "/tmp/RtmpBx9Hdj/test_its-example.osm.pbf"

if (FALSE) { # \dontrun{
oe_find("Isle of Wight", download_directory = tempdir())
oe_find("Malta", download_if_missing = TRUE, download_directory = tempdir())
oe_find(
  "Leeds",
  provider = "bbbike",
  download_if_missing = TRUE,
  download_directory = tempdir(),
  return_pbf = FALSE
)} # }

# Remove .pbf and .gpkg files in tempdir
oe_clean(tempdir())
```
