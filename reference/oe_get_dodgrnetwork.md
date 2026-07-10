# Obtain a dodgr_streetnet object from OpenStreetMap data

This function is a wrapper around
[`oe_get_network()`](https://docs.ropensci.org/osmextract/reference/oe_get_network.md)
that returns a `dodgr_streetnet` object. It performs simplification of
the highway values, filters by highway types and standardises the
`oneway` attribute as well as applying the implied oneway restriction
based on the \`junction“ tag values.

## Usage

``` r
oe_get_dodgrnetwork(
  place,
  mode = c("cycling", "driving", "walking"),
  ...,
  highway_filter = NULL,
  quiet = FALSE
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

- mode:

  A character string of length one denoting the desired mode of
  transport. Can be abbreviated. Currently `cycling` (the default),
  `driving` and `walking` are supported.

- ...:

  additional parameters passed to
  [`oe_get_network()`](https://docs.ropensci.org/osmextract/reference/oe_get_network.md)
  and
  [`dodgr::weight_streetnet()`](https://UrbanAnalyst.github.io/dodgr/reference/weight_streetnet.html),
  excluding `x` and `id_col` for the latter.

- highway_filter:

  Character vector of highway types to keep. Ignored if `NULL`. Valid
  values are: "busway", "cycleway", "footway", "living_street",
  "motorway", "path", "pedestrian", "primary", "residential",
  "rest_area", "service", "services", "steps", "tertiary", "track",
  "trunk" and "unclassified".

- quiet:

  Boolean. If `FALSE`, the function prints informative messages.
  Starting from `sf` version
  [0.9.6](https://r-spatial.github.io/sf/news/index.html#version-0-9-6-2020-09-13),
  if `quiet` is equal to `FALSE`, then vectortranslate operations will
  display a progress bar.

## Value

A `dodgr_streetnet` object

## See also

[`oe_get()`](https://docs.ropensci.org/osmextract/reference/oe_get.md),
[`oe_get_network()`](https://docs.ropensci.org/osmextract/reference/oe_get_network.md),
[`oe_get_sfnetwork()`](https://docs.ropensci.org/osmextract/reference/oe_get_sfnetwork.md)

## Examples

``` r
# Copy the ITS file to tempdir() to make sure that the examples do not
# require internet connection. You can skip the next 4 lines (and start
# directly with oe_get_keys) when running the examples locally.
its_pbf = file.path(tempdir(), "test_its-example.osm.pbf")
file.copy(
  from = system.file("its-example.osm.pbf", package = "osmextract"),
  to = its_pbf,
  overwrite = TRUE
)
#> [1] TRUE

if (requireNamespace("dodgr", quietly = TRUE)) {
  graph_bike <- oe_get_dodgrnetwork(
    place = "ITS Leeds",
    mode = "cycling",
    wt_profile = "bicycle",
    left_side = TRUE,
    download_directory = tempdir(),
    quiet = TRUE
  )
  head(graph_bike)

  highway_filter = c(
    "motorway",
    "trunk",
    "primary",
    "secondary",
    "tertiary",
    "unclassified",
    "residential"
  )

  graph_car <- oe_get_dodgrnetwork(
    place = "ITS Leeds",
    mode = "driving",
    wt_profile = "motorcar",
    left_side = TRUE,
    highway_filter = highway_filter,
    download_directory = tempdir(),
    quiet = TRUE
  )

  head(graph_car)
  class(graph_car)
}
#> [1] "dodgr_streetnet" "data.frame"     
```
