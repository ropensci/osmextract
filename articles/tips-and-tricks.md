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

## How can I convert the segments downloaded from OSM into a street network?

Starting from version 0.7, the package includes a set of functions to
automatically convert the output of
[`oe_get_network()`](https://docs.ropensci.org/osmextract/reference/oe_get_network.md)
(and similar functions) into `sfnetwork` or `dodgr` objects.

For example, the following command returns a `sfnetwork` object
representing the walking network extracted from the toy ITS data
included in the package:

``` r

sfn_walking = oe_get_sfnetwork(
  place = "ITS Leeds",
  mode = "walking", 
  quiet = TRUE
)
#> Warning: to_spatial_subdivision assumes attributes are constant over geometries
```

More precisely, the function runs the following operations:

1.  It extracts the walkable streets from the toy ITS Leeds data
    included in the package;
2.  It applies a series of preprocessing steps to standardise the values
    included in the `oneway` column and simplies the `highway` tag
    removing the `"_link"` suffix. See the `clean_output` argument in
    `oe_get_network` for more details.
3.  It converts the data into `sfnetwork` class and applies two spatial
    morphers, namely `to_spatial_subdivision` and `to_spatial_smooth` to
    fix possible inconsistencies in the geometries and simplify the
    geometry structure. See also
    [`?net_2_sfnet_undirected`](https://docs.ropensci.org/osmextract/reference/net_2_sfnet_undirected.md);
4.  If requested, converts the output into a directed network after
    duplicating bidirectional edges with reversed geometries.

The following command runs similar operations (except for the spatial
morphers) and returns a `dodgr_streenet` object:

``` r

dodgr_walking = oe_get_dodgrnetwork(
  place = "ITS Leeds",
  mode = "walking", 
  quiet = TRUE
)
#> Warning in oe_get_dodgrnetwork(place = "ITS Leeds", mode = "walking", quiet = TRUE): The 'oneway'
#> column is missing. All edges will be assumed to be bidirectional!
```

See the help pages of the corresponding functions for more details.
