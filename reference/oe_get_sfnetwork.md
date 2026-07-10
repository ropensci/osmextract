# Obtain a sfnetwork object from OpenStreetMap data

This function is a wrapper around
[`oe_get_network()`](https://docs.ropensci.org/osmextract/reference/oe_get_network.md)
that returns a `sfnetwork` object. It performs simplification of the
highway values and filters by highway types if specified. Minimal
network preprocessing tasks i.e. subdivision and smoothing are
performed. It also allows for the creation of directed or undirected
networks.

## Usage

``` r
oe_get_sfnetwork(
  place,
  mode = c("cycling", "driving", "walking"),
  ...,
  require_equal = TRUE,
  directed = FALSE,
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

  Additional arguments passed to
  [`oe_get_network()`](https://docs.ropensci.org/osmextract/reference/oe_get_network.md).

- require_equal:

  logical or character vector. Defaults to `TRUE.` If `TRUE`, only
  pseudo nodes that have incident edges with equal attribute values are
  removed. Alternatively, a character vector with the names of the
  attributes to check for equality can be provided. In that case, only
  those attributes are checked for equality. If `FALSE`, all pseudo
  nodes are removed regardless of attribute values. All other attributes
  are collapsed, separating the values by a comma.

- directed:

  logical, whether to return a directed sfnetwork object (default is
  `FALSE`)

- highway_filter:

  Character vector of highway types to keep. Ignored if clean_output is
  `FALSE`. Valid values are: "busway", "cycleway", "footway",
  "living_street", "motorway", "path", "pedestrian", "primary",
  "residential", "rest_area", "service", "services", "steps",
  "tertiary", "track", "trunk" and "unclassified".

- quiet:

  Boolean. If `FALSE`, the function prints informative messages.
  Starting from `sf` version
  [0.9.6](https://r-spatial.github.io/sf/news/index.html#version-0-9-6-2020-09-13),
  if `quiet` is equal to `FALSE`, then vectortranslate operations will
  display a progress bar.

## Value

An `sfnetwork` object

## Details

In particular, the two preprocessing morphers applied to the output
returned by
[`oe_get_network()`](https://docs.ropensci.org/osmextract/reference/oe_get_network.md)
are
[`sfnetworks::to_spatial_subdivision()`](https://luukvdmeer.github.io/sfnetworks/reference/spatial_morphers.html)
and
[`sfnetworks::to_spatial_smooth()`](https://luukvdmeer.github.io/sfnetworks/reference/spatial_morphers.html).
Check their help pages for more details. See also the documentation for
`sfnetworks` for more details on the two preprocessing steps:
[subdividing
edges](https://luukvdmeer.github.io/sfnetworks/articles/sfn02_preprocess_clean.html#subdivide-edges)
and [smoothing
pseudo-nodes](https://luukvdmeer.github.io/sfnetworks/articles/sfn02_preprocess_clean.html#smooth-pseudo-nodes).

Note that preprocessing is performed on the undirected graph, ignoring
road directionality. If `directed = TRUE`, the function then builds the
directed graph by duplicating bidirectional edges with reversed
geometries. If the `oneway` column is missing, a warning is issued and
an undirected `sfnetwork` is returned instead.

## See also

[`oe_get()`](https://docs.ropensci.org/osmextract/reference/oe_get.md),
[`oe_get_network()`](https://docs.ropensci.org/osmextract/reference/oe_get_network.md),
[`oe_get_dodgrnetwork()`](https://docs.ropensci.org/osmextract/reference/oe_get_dodgrnetwork.md)

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
if (requireNamespace("sfnetworks", quietly = TRUE)) {
  #' # Undirected unfiltered pedestrian network
  walk_sfnet <- oe_get_sfnetwork(
    place = "ITS Leeds",
    mode = "walking",
    download_directory = tempdir(),
    quiet = TRUE
  )
  plot(walk_sfnet)

  #' # Directed unfiltered driving network
  car_sfnet <- oe_get_sfnetwork(
    place = "ITS Leeds",
    mode = "driving",
    directed = TRUE,
    download_directory = tempdir(),
    quiet = TRUE
  )
  plot(car_sfnet)

  #' # Directed filtered driving network
  highway_filter = c(
    "motorway",
    "trunk",
    "primary",
    "secondary",
    "tertiary",
    "unclassified",
    "residential"
  )

  car_sfnet_filtered <- oe_get_sfnetwork(
    place = "ITS Leeds",
    mode = "driving",
    directed = TRUE,
    highway_filter = highway_filter,
    download_directory = tempdir(),
    quiet = TRUE
  )
  plot(car_sfnet_filtered)

  # Smooth pseudo nodes when highway and oneway fields are equal
  car_sfnet_filtered_2 <- oe_get_sfnetwork(
    place = "ITS Leeds",
    mode = "driving",
    directed = TRUE,
    highway_filter = highway_filter,
    require_equal = c("highway", "oneway"),
    download_directory = tempdir(),
    quiet = TRUE
  )
  plot(car_sfnet_filtered_2)
}
#> Warning: to_spatial_subdivision assumes attributes are constant over geometries

#> Warning: to_spatial_subdivision assumes attributes are constant over geometries

#> Warning: to_spatial_subdivision assumes attributes are constant over geometries

#> Warning: to_spatial_subdivision assumes attributes are constant over geometries
```
