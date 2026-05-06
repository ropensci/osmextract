# Get the administrative boundary for a given place

This function can be used to obtain polygon/multipolygon objects
representing an administrative boundary. The objects are extracted from
the `multipolygons` layer of a given OSM extract.

## Usage

``` r
oe_get_boundary(place, name = place, exact = TRUE, ...)
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

- name:

  A character vector of length 1 that describes the relevant area. By
  default, this is equal to `place`, but this parameter can be tuned to
  obtain more granular results starting from the same OSM extract. See
  examples. It must be always set when the `place` argument is specified
  using numeric or spatial (i.e. `sf/sfc`) objects.

- exact:

  Boolean of length 1. If `TRUE`, the function returns only those
  features where the field `name` is exactly equal to `name`. If
  `FALSE`, it performs a (case-sensitive) pattern matching.

- ...:

  Further arguments (e.g. `quiet` or `force_vectortranslate`) that are
  passed to
  [`oe_get()`](https://docs.ropensci.org/osmextract/reference/oe_get.md).

## Value

An `sf` object

## Details

The function may return an empty result when the corresponding .gpkg
file already exists and contains partial results. In that case, you can
try running the function again setting
`never_skip_vectortranslate = TRUE`.

## Examples

``` r
if (FALSE) { # \dontrun{
library(sf)
gabon = oe_get_boundary("Gabon", quiet = TRUE) # country
libreville = oe_get_boundary("Gabon", "Libreville", quiet = TRUE) # capital

opar = par(mar = rep(0, 4))
plot(st_geometry(st_boundary(gabon)), reset = FALSE, col = "grey")
my_cols = sf.colors(5, categorical = TRUE)
plot(st_geometry(libreville), add = TRUE, col = my_cols[1])

# Exact match
komo = oe_get_boundary("Gabon", "Komo", quiet = TRUE)
# Pattern matching
komo_pt = oe_get_boundary("Gabon", "Komo", exact = FALSE, quiet = TRUE)
plot(st_geometry(komo), add = TRUE, col = my_cols[2])
plot(st_geometry(komo_pt), add = TRUE, col = my_cols[3:5])
par(opar)

# Get all boundaries
(gabon = oe_get_boundary("Gabon", name = "%", exact = FALSE, quiet = TRUE)[, 1:2])
plot(st_geometry(gabon))

# If the basic approach doesn't work, e.g.
oe_get_boundary("Leeds")

# try to consider larger regions, i.e.
oe_get_boundary("West Yorkshire", "Leeds")
} # }
```
