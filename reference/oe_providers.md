# Summary of available providers

This function is used to display a short summary of the major
characteristics of the databases associated to all available providers.

## Usage

``` r
oe_providers()
```

## Value

A `data.frame` with 4 columns representing the name of each available
provider, the name of the corresponding database and the number of
features and fields.

## See also

[geofabrik_zones](https://docs.ropensci.org/osmextract/reference/geofabrik_zones.md),
[bbbike_zones](https://docs.ropensci.org/osmextract/reference/bbbike_zones.md),
[openstreetmap_fr_zones](https://docs.ropensci.org/osmextract/reference/openstreetmap_fr_zones.md)

## Examples

``` r
oe_providers()
#>   available_providers          database_name number_of_zones number_of_fields
#> 1           geofabrik        geofabrik_zones             512                8
#> 2              bbbike           bbbike_zones             238                5
#> 3    openstreetmap_fr openstreetmap_fr_zones            1190                6
```
