
<!-- README.md is generated from README.Rmd. Please edit that file -->

# geofabric

<!-- badges: start -->

<!-- badges: end -->

The goal of geofabric is to provide easy access to OSM data shipped by
[geofrabric](http://download.geofabrik.de).

## Installation

<!-- You can install the released version of geofabric from [CRAN](https://CRAN.R-project.org) with: -->

<!-- ``` r -->

<!-- install.packages("geofabric") -->

<!-- ``` -->

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ITSLeeds/geofabric")
```

## Usage

Give geofabric the name of a country and it will try to download it,
e.g.:

``` r
library(geofabric)
get_geofabric(continent = "europe", country = "andorra")
#> Trying http://download.geofabrik.de/europe/andorra-latest-free.shp.zip
#> Downloading http://download.geofabrik.de/europe/andorra-latest-free.shp.zip
#> The following shapefiles have been downloaded:
#>  [1] "/tmp/RtmpwlGXhe/gis_osm_buildings_a_free_1.shp"
#>  [2] "/tmp/RtmpwlGXhe/gis_osm_landuse_a_free_1.shp"  
#>  [3] "/tmp/RtmpwlGXhe/gis_osm_natural_a_free_1.shp"  
#>  [4] "/tmp/RtmpwlGXhe/gis_osm_natural_free_1.shp"    
#>  [5] "/tmp/RtmpwlGXhe/gis_osm_places_a_free_1.shp"   
#>  [6] "/tmp/RtmpwlGXhe/gis_osm_places_free_1.shp"     
#>  [7] "/tmp/RtmpwlGXhe/gis_osm_pofw_a_free_1.shp"     
#>  [8] "/tmp/RtmpwlGXhe/gis_osm_pofw_free_1.shp"       
#>  [9] "/tmp/RtmpwlGXhe/gis_osm_pois_a_free_1.shp"     
#> [10] "/tmp/RtmpwlGXhe/gis_osm_pois_free_1.shp"       
#> [11] "/tmp/RtmpwlGXhe/gis_osm_railways_free_1.shp"   
#> [12] "/tmp/RtmpwlGXhe/gis_osm_roads_free_1.shp"      
#> [13] "/tmp/RtmpwlGXhe/gis_osm_traffic_a_free_1.shp"  
#> [14] "/tmp/RtmpwlGXhe/gis_osm_traffic_free_1.shp"    
#> [15] "/tmp/RtmpwlGXhe/gis_osm_transport_a_free_1.shp"
#> [16] "/tmp/RtmpwlGXhe/gis_osm_transport_free_1.shp"  
#> [17] "/tmp/RtmpwlGXhe/gis_osm_water_a_free_1.shp"    
#> [18] "/tmp/RtmpwlGXhe/gis_osm_waterways_free_1.shp"
```

If there are no files available for that country, only regions, it will
tell you:

``` r
get_geofabric(continent = "europe", country = "great-britain")
#> Trying http://download.geofabrik.de/europe/great-britain-latest-free.shp.zip
#> No country file to download. See http://download.geofabrik.de/europe/great-britain for available regions.
#> [1] "http://download.geofabrik.de/europe/great-britain"
```

Download a specific region as
follows:

``` r
# get_geofabric(continent = "europe", country = "great-britain", region = "wales")
# get_geofabric(continent = "europe", country = "italy", region = "nord-este")
```
