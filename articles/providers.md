# Add new OpenStreetMap providers

This vignette aims to provide a simple guide on adding a new provider to
`osmextract`. Let’ start loading the package:

``` r

library(osmextract)
#> Data (c) OpenStreetMap contributors, ODbL 1.0. https://www.openstreetmap.org/copyright.
#> Check the package website, https://docs.ropensci.org/osmextract/, for more details.
```

As of summer 2020, there are several services providing bulk OSM
datasets listed
[here](https://wiki.openstreetmap.org/wiki/Processed_data_providers) and
[here](https://wiki.openstreetmap.org/wiki/Planet.osm#Country_and_area_extracts).
At the moment, we support the following providers:

``` r

oe_providers()
#>   available_providers          database_name number_of_zones number_of_fields
#> 1           geofabrik        geofabrik_zones             512                8
#> 2              bbbike           bbbike_zones             238                5
#> 3    openstreetmap_fr openstreetmap_fr_zones            1190                6
```

Check the “Comparing the supported OSM providers” for more details on
the existing providers.

This package is designed to make it easy to add new providers. There are
three main steps to add a new provider: creating the zones, adding the
provider and documenting it. They are outlined below.

## Adding a `provider_zones` object to the package

The first and hardest step is to create an `sf` object analogous to the
`test_zones` object shown below:

``` r

names(test_zones)
#> [1] "id"            "name"          "parent"        "level"        
#> [5] "pbf_file_size" "pbf"           "geometry"
str(test_zones[, c(2, 6, 7)])
#> Classes 'sf' and 'data.frame':   2 obs. of  3 variables:
#>  $ name    : chr  "Isle of Wight" "ITS Leeds"
#>  $ pbf     : chr  "https://github.com/ropensci/osmextract/releases/download/0.0.1/geofabrik_isle-of-wight-latest.osm.pbf" "https://github.com/ropensci/osmextract/raw/master/inst/its-example.osm.pbf"
#>  $ geometry:sfc_POLYGON of length 2; first list element: List of 1
#>   ..$ : num [1:7, 1:2] -1.52 -1.66 -1.31 -1.11 -1.03 ...
#>   ..- attr(*, "class")= chr [1:3] "XY" "POLYGON" "sfg"
#>  - attr(*, "sf_column")= chr "geometry"
#>  - attr(*, "agr")= Factor w/ 3 levels "constant","aggregate",..: NA NA
#>   ..- attr(*, "names")= chr [1:2] "name" "pbf"
```

The output shows the three most important column names:

1.  The zone `name` (that is used for matching the input `place`, see
    [`oe_match()`](https://docs.ropensci.org/osmextract/reference/oe_match.md));
2.  The URL endpoint where `.pbf` files associated with each zone can be
    downloaded;
3.  The geometry, representing the spatial extent of the dataset.

The object must also include the fields `level` and `id`, which are
used, respectively, for spatial matching and updating. See
[`oe_match()`](https://docs.ropensci.org/osmextract/reference/oe_match.md)
and
[`oe_update()`](https://docs.ropensci.org/osmextract/reference/oe_update.md).

The best way to start creating a new `_zones` object for a new provider
is probably by looking at the code we wrote for the first supported
provider in
[`data-raw/geofabrik_zones.R`](https://github.com/ropensci/osmextract/blob/master/data-raw/geofabrik_zones.R).
The following commands will clone this repo and open the relevant file:

``` bash
git clone git@github.com:ropensci/osmextract
rstudio osmextract/osmextract.Rproj
```

Then in RStudio:

``` r

file.edit("data-raw/geofabrik_zones.R")
```

Create a new script to document the code that generates the new object,
e.g. for `bbbike`:

``` r

file.edit("data-raw/bbbike_zones.R")
# or, even better, use
usethis::use_data_raw("bbbike_zones")
```

After you have created the new provider `_zones` file, it’s time to add
the provider to the package.

## Adding the new provider to the package

Once you have created your overview `_zones` file as outlined in the
previous step, you need to modify the following files for the provider
to be available for others:

- [data.R](https://github.com/ropensci/osmextract/blob/master/R/data.R),
  where you’ll need to document the new dataset;
- [globals.R](https://github.com/ropensci/osmextract/blob/master/R/globals.R),
  where you’ll need to add the new object name;
- [providers.R](https://github.com/ropensci/osmextract/blob/master/R/providers.R),
  where you’ll need to add the new object name in
  `oe_available_providers()` and `load_provider_data()`.

## Documenting the provider

The final step is also the most fun: documenting and using the provider.
Add an example, mention it in the README and tell others about what this
new provider can do! If you want to ask for help on adding a new
provider, feel free to open in a new issue in the [github
repository](https://github.com/ropensci/osmextract)!

## Conclusion

This vignette talks through the main steps needed to extend `osmextract`
by adding new OSM data providers. To see the same information in code
form, see the PR that implemented the `openstreetmap_fr` provider here:
<https://github.com/ropensci/osmextract/commit/dbf131667a80e5a6837a6c8eb3b967075e1aba16>
