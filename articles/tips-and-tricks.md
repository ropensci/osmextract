# Tips and tricks for using the package

This vignette presents a collection of useful tips and tricks we’ve
gathered over the years for effectively using this package to read,
download, and filter OpenStreetMap (OSM) extracts. First of all, let’s
load the relevant packages:

``` r

library(osmextract)
#> Data (c) OpenStreetMap contributors, ODbL 1.0. https://www.openstreetmap.org/copyright.
#> Check the package website, https://docs.ropensci.org/osmextract/, for more details.
```

## How can I get OSM objects by node/way id number?

The example below demonstrates how to select a set of ways from an OSM
extract, assuming you already know their OSM IDs:

``` r

osm_id <- c("4419868", "6966733", "7989989", "15333726", "31705837")

out <- oe_get(
  place = "ITS Leeds",
  query = paste0(
    "SELECT * FROM lines WHERE osm_id IN (", paste0(osm_id, collapse = ","), ")"
  ), 
  quiet = TRUE
)
print(out, n = 0L)
#> Simple feature collection with 5 features and 10 fields
#> Geometry type: LINESTRING
#> Dimension:     XY
#> Bounding box:  xmin: -1.5609 ymin: 53.8063 xmax: -1.549451 ymax: 53.81044
#> Geodetic CRS:  WGS 84
```
