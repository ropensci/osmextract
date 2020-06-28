
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Load package

``` r
library(osmextractr)
#> Data (c) OpenStreetMap contributors, ODbL 1.0. https://www.openstreetmap.org/copyright
#> Geofabrik data are taken from https://download.geofabrik.de/
```

# Test matching

``` r
osmext_match("Italy")
#> $pbf_url
#> [1] "https://download.geofabrik.de/europe/italy-latest.osm.pbf"
#> 
#> $pbf_file_size
#> [1] 1544340778
osmext_match("Italy", provider = "bbbike") #TODO
#> Error: You can only select one of the following providers: geofabrik
osmext_match(c(9, 45)) #TODO, crs = 4326 is implicit in this case
#> Error: At the moment there is no support for matching objects of class numeric. Feel free to open a new issue at ... .
osmext_match(sf::st_sfc(sf::st_point(c(1680146.94, 4851840.10)), crs = 3003)) #TODO
#> Error: At the moment there is no support for matching objects of class sfc_POINT. Feel free to open a new issue at ... .

osmext_match("US")
#> No exact matching found for place = US. Best match is Sud.
#> Error: String distance between best match and the input place is 2, while the maximum threshold distance is equal to 1. You should increase the max_string_dist parameter, look for a closer match in the chosen provider database or consider using a different match_by variable.
osmext_match("US", match_by = "iso3166_1_alpha2") # matching by iso3166 is really powerful IMO but it should be documented
#> $pbf_url
#> [1] "https://download.geofabrik.de/north-america/us-latest.osm.pbf"
#> 
#> $pbf_file_size
#> [1] 6982945396

osmext_match("Korea") # Add one function to explore matches with grep
#> No exact matching found for place = Korea. Best match is Azores.
#> Error: String distance between best match and the input place is 3, while the maximum threshold distance is equal to 1. You should increase the max_string_dist parameter, look for a closer match in the chosen provider database or consider using a different match_by variable.
osmext_match("Russia") # Add one function to explore matches with grep
#> No exact matching found for place = Russia. Best match is Asia.
#> Error: String distance between best match and the input place is 3, while the maximum threshold distance is equal to 1. You should increase the max_string_dist parameter, look for a closer match in the chosen provider database or consider using a different match_by variable.
osmext_match("RU", match_by = "iso3166_1_alpha2")
#> $pbf_url
#> [1] "https://download.geofabrik.de/russia-latest.osm.pbf"
#> 
#> $pbf_file_size
#> [1] 2820253009
osmext_match("Isle Wight", max_string_dist = 3)
#> $pbf_url
#> [1] "https://download.geofabrik.de/europe/great-britain/england/isle-of-wight-latest.osm.pbf"
#> 
#> $pbf_file_size
#> [1] 6877468
```

# Test download

``` r
iow = osmext_match("Isle Wight", max_string_dist = 3)
osmext_download(
  file_url = iow$pbf_url, 
  file_size = iow$pbf_file_size
)
#> [1] "/tmp/RtmpmldZS1/geofabrik_isle-of-wight-latest.osm.pbf"
```
