
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Load package

``` r
library(osmextractr)
#> Data (c) OpenStreetMap contributors, ODbL 1.0. https://www.openstreetmap.org/copyright
#> Geofabrik data are taken from https://download.geofabrik.de/
```

The packages is composed by 4 main functions:

1.  `osmext_match`: Match the input zone with one of the files stored by
    the OSM providers
2.  `osmext_download`: Download the chosen file
3.  `osmext_vectortranslate`: Convert the pbf format into gpkg
4.  `osmext_read`: Read the gpkg file

# Test `osmext_match`

The simplest case:

``` r
osmext_match("Italy")
#> $url
#> [1] "https://download.geofabrik.de/europe/italy-latest.osm.pbf"
#> 
#> $file_size
#> [1] 1544340778
```

The input `place` can be also specified using an `sfc_POINT` object with
arbitrary CRS:

``` r
coords_milan = sf::st_point(c(1514924.21, 5034552.92))
st_sfc_milan = sf::st_sfc(coords_milan, crs = 3003)
osmext_match(st_sfc_milan)
#> although coordinates are longitude/latitude, st_intersects assumes that they are planar
#> $url
#> [1] "https://download.geofabrik.de/europe/italy/nord-ovest-latest.osm.pbf"
#> 
#> $file_size
#> [1] 416306623
```

``` r
osmext_match("Italy", provider = "bbbike") #TODO
osmext_match(c(9, 45)) #TODO, crs = 4326 is implicit in this case
osmext_match(sf::st_sfc(sf::st_point(c(1680146.94, 4851840.10)), crs = 3003)) #TODO

osmext_match("US")
osmext_match("US", match_by = "iso3166_1_alpha2") # matching by iso3166 is really powerful IMO but it should be documented

osmext_match("Korea") # Add one function to explore matches with grep
osmext_match("Russia") # Add one function to explore matches with grep
osmext_match("RU", match_by = "iso3166_1_alpha2")
osmext_match("Isle Wight", max_string_dist = 3)
```

# Test download

``` r
iow = osmext_match("Isle Wight", max_string_dist = 3)
osmext_download(
  file_url = iow$pbf_url, 
  file_size = iow$pbf_file_size
)
```
