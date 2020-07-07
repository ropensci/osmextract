
<!-- README.md is generated from README.Rmd. Please edit that file -->

The leitmotif of package is to help the users to read and download
extracts of OpenStreetMap data stored by several providers, such as
[Geofabrik](http://download.geofabrik.de/) or
[bbbike](https://download.bbbike.org/osm/bbbike/). The provider’s data
are stored using `sf` objects that summarize the most important
characteristics of each geographic zone, such as the name and the url of
the pbf file.

``` r
library(sf)
#> Linking to GEOS 3.8.0, GDAL 3.0.4, PROJ 7.0.0
osmextractr::geofabrik_zones[, c(2, 8)]
#> Simple feature collection with 430 features and 2 fields
#> geometry type:  MULTIPOLYGON
#> dimension:      XY
#> bbox:           xmin: -180 ymin: -90 xmax: 180 ymax: 85.04177
#> geographic CRS: WGS 84
#> First 10 features:
#>           name                                                                       pbf                       geometry
#> 1  Afghanistan             https://download.geofabrik.de/asia/afghanistan-latest.osm.pbf MULTIPOLYGON (((62.47808 29...
#> 2       Africa                       https://download.geofabrik.de/africa-latest.osm.pbf MULTIPOLYGON (((11.60092 33...
#> 3      Albania               https://download.geofabrik.de/europe/albania-latest.osm.pbf MULTIPOLYGON (((19.37748 42...
#> 4      Alberta https://download.geofabrik.de/north-america/canada/alberta-latest.osm.pbf MULTIPOLYGON (((-110.0051 4...
#> 5      Algeria               https://download.geofabrik.de/africa/algeria-latest.osm.pbf MULTIPOLYGON (((6.899245 37...
#> 6         Alps                  https://download.geofabrik.de/europe/alps-latest.osm.pbf MULTIPOLYGON (((5.57178 48....
#> 7       Alsace         https://download.geofabrik.de/europe/france/alsace-latest.osm.pbf MULTIPOLYGON (((8.236555 48...
#> 8      Andorra               https://download.geofabrik.de/europe/andorra-latest.osm.pbf MULTIPOLYGON (((1.516233 42...
#> 9       Angola                https://download.geofabrik.de/africa/angola-latest.osm.pbf MULTIPOLYGON (((20.72182 -1...
#> 10  Antarctica                   https://download.geofabrik.de/antarctica-latest.osm.pbf MULTIPOLYGON (((-180 -90, 1...
```

## Load package

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

The function `osmext_get` is a wrapper around all of them.

# Test `osmext_match`

The simplest example:

``` r
osmext_match("Italy")
#> $url
#> [1] "https://download.geofabrik.de/europe/italy-latest.osm.pbf"
#> 
#> $file_size
#> [1] 1544340778
```

There are several situations where it could be difficult to find the
appropriate data source due to several small differences in the official
names:

``` r
osmext_match("Korea")
#> Error: String distance between best match and the input place is 3, while the maximum threshold distance is equal to 1. You should increase the max_string_dist parameter, look for a closer match in the chosen provider database or consider using a different match_by variable.
osmext_match("Russia")
#> Error: String distance between best match and the input place is 3, while the maximum threshold distance is equal to 1. You should increase the max_string_dist parameter, look for a closer match in the chosen provider database or consider using a different match_by variable.
```

For these reasons we implemented the possibility to look for the
appropriate area according to the [iso3166-1
alpha2](https://it.wikipedia.org/wiki/ISO_3166-1_alpha-2) code:

``` r
osmext_match("KP", match_by = "iso3166_1_alpha2")
#> $url
#> [1] "https://download.geofabrik.de/asia/north-korea-latest.osm.pbf"
#> 
#> $file_size
#> [1] 33241783
osmext_match("RU", match_by = "iso3166_1_alpha2")
#> $url
#> [1] "https://download.geofabrik.de/russia-latest.osm.pbf"
#> 
#> $file_size
#> [1] 2820253009
osmext_match("US", match_by = "iso3166_1_alpha2")
#> $url
#> [1] "https://download.geofabrik.de/north-america/us-latest.osm.pbf"
#> 
#> $file_size
#> [1] 6982945396
```

The are a few cases where the `iso3166-1 alpha2` codes can fail because
there are no per-country extracts (e.g. Israel and Palestine)

``` r
osmext_match("PS", match_by = "iso3166_1_alpha2")
#> Error: String distance between best match and the input place is 1, while the maximum threshold distance is equal to 0. You should increase the max_string_dist parameter, look for a closer match in the chosen provider database or consider using a different match_by variable.
osmext_match("IL", match_by = "iso3166_1_alpha2")
#> Error: String distance between best match and the input place is 1, while the maximum threshold distance is equal to 0. You should increase the max_string_dist parameter, look for a closer match in the chosen provider database or consider using a different match_by variable.
```

For this reason we also created a function that let you explore the
matching variables according to a chosen pattern, for example:

``` r
osmext_check_pattern("London")
#> [1] "Greater London"
osmext_check_pattern("Russia")
#> [1] "Russian Federation"
osmext_check_pattern("Korea")
#> [1] "North Korea" "South Korea"
osmext_check_pattern("Yorkshire")
#> [1] "East Yorkshire with Hull" "North Yorkshire"          "South Yorkshire"          "West Yorkshire"
osmext_check_pattern("US")
#> [1] "US Midwest"         "US Northeast"       "US Pacific"         "US South"           "US West"            "Georgia (US State)"
osmext_check_pattern("US", match_by = "iso3166_2")
#>  [1] "US-AL" "US-AK" "US-AZ" "US-AR" "US-CA" "US-CO" "US-CT" "US-DE" "US-DC" "US-FL" "US-GA" "US-HI" "US-ID" "US-IL" "US-IN" "US-IA" "US-KS"
#> [18] "US-KY" "US-LA" "US-ME" "US-MD" "US-MA" "US-MI" "US-MN" "US-MS" "US-MO" "US-MT" "US-NE" "US-NV" "US-NH" "US-NJ" "US-NM" "US-NY" "US-NC"
#> [35] "US-ND" "US-OH" "US-OK" "US-OR" "US-PA" "US-PR" "US-RI" "US-SC" "US-SD" "US-TN" "US-TX" "US-UT" "US-VT" "US-VA" "US-WA" "US-WV" "US-WI"
#> [52] "US-WY"
osmext_check_pattern("Palestine")
#> [1] "Israel and Palestine"
osmext_check_pattern("Israel", full_row = TRUE)
#> Simple feature collection with 1 feature and 14 fields
#> geometry type:  MULTIPOLYGON
#> dimension:      XY
#> bbox:           xmin: 34.07929 ymin: 29.37711 xmax: 35.91531 ymax: 33.35091
#> geographic CRS: WGS 84
#>                       id                 name parent level iso3166_1_alpha2 iso3166_2 pbf_file_size
#> 151 israel-and-palestine Israel and Palestine   asia     2            PS IL      <NA>      82361911
#>                                                                        pbf
#> 151 https://download.geofabrik.de/asia/israel-and-palestine-latest.osm.pbf
#>                                                                        bz2
#> 151 https://download.geofabrik.de/asia/israel-and-palestine-latest.osm.bz2
#>                                                                             shp
#> 151 https://download.geofabrik.de/asia/israel-and-palestine-latest-free.shp.zip
#>                                                                                     pbf.internal
#> 151 https://osm-internal.download.geofabrik.de/asia/israel-and-palestine-latest-internal.osm.pbf
#>                                                                                   history
#> 151 https://osm-internal.download.geofabrik.de/asia/israel-and-palestine-internal.osh.pbf
#>                                                     taginfo                                                         updates
#> 151 https://taginfo.geofabrik.de/asia/israel-and-palestine/ https://download.geofabrik.de/asia/israel-and-palestine-updates
#>                           geometry
#> 151 MULTIPOLYGON (((34.64563 32...
```

The input `place` can be also specified using an `sfc_POINT` object with
arbitrary CRS as documented in the following example. If there are
multiple matches, the function returns the smallest area (according to
the `level` variable). I would ignore the CRS warning for the moment.

``` r
coords_milan = sf::st_point(c(1514924.21, 5034552.92)) # Duomo di Milano
st_sfc_milan = sf::st_sfc(coords_milan, crs = 3003)
osmext_match(st_sfc_milan)
#> although coordinates are longitude/latitude, st_intersects assumes that they are planar
#> $url
#> [1] "https://download.geofabrik.de/europe/italy/nord-ovest-latest.osm.pbf"
#> 
#> $file_size
#> [1] 416306623
```

The input `place` can be also specified using a numeric vector of
coordinates. In that case the CRS is assumed to be 4326:

``` r
osmext_match(c(9.1916, 45.4650)) # Duomo di Milano
#> although coordinates are longitude/latitude, st_intersects assumes that they are planar
#> $url
#> [1] "https://download.geofabrik.de/europe/italy/nord-ovest-latest.osm.pbf"
#> 
#> $file_size
#> [1] 416306623
osmext_match(c(9.1916, 45.4650, 9.2020, 45.4781))
#> Error in osmext_match.numeric(c(9.1916, 45.465, 9.202, 45.4781)): You need to provide a pair of coordinates and you passed as input a vector of length 4
# osmext_match(c(9.1916, 45.4650), c(9.2020, 45.4781)) FIXME with suitable check and error
```

If there are several error matching the input place with one of the
zone, you can also try increasing the maximum allowed string distance:

``` r
osmext_match("Isle Wight")
#> Error: String distance between best match and the input place is 3, while the maximum threshold distance is equal to 1. You should increase the max_string_dist parameter, look for a closer match in the chosen provider database or consider using a different match_by variable.
osmext_match("Isle Wight", max_string_dist = 3)
#> $url
#> [1] "https://download.geofabrik.de/europe/great-britain/england/isle-of-wight-latest.osm.pbf"
#> 
#> $file_size
#> [1] 6877468
```

## Test `osmext_download`

The simplest example:

``` r
iow = osmext_match("Isle of Wight")
osmext_download(
  file_url = iow$url, 
  file_size = iow$file_size
)
#> [1] "/tmp/Rtmpu4ZpAp/geofabrik_isle-of-wight-latest.osm.pbf"
```

If you want to download your data into a persistent directory, set
`OSMEXT_DOWNLOAD_DIRECTORY=/path/for/osm/data` in your `.Renviron` file,
e.g. with `usethis::edit_r_environ()` or manually. For example:

``` r
Sys.setenv("OSMEXT_DOWNLOAD_DIRECTORY" = "~/osmext_data")
osmext_download(
  file_url = iow$url, 
  file_size = iow$file_size
)
#> [1] "~/osmext_data/geofabrik_isle-of-wight-latest.osm.pbf"
```
