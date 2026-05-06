# Get default osmconf.ini

Returns the path to the `CONFIG` file used by this package when running
the `.osm.pbf` -\> `.gpkg` conversion

## Usage

``` r
get_default_osmconf_ini()
```

## Value

Path to the file

## Examples

``` r
get_default_osmconf_ini()
#> [1] "/usr/share/gdal/osmconf.ini"
```
