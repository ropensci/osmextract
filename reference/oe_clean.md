# Clean download directory

This functions is a wrapper around
[`unlink()`](https://rdrr.io/r/base/unlink.html) that can be used to
delete all `.osm.pbf` and `.gpkg` files in a given directory.

## Usage

``` r
oe_clean(download_directory = oe_download_directory(), force = FALSE)
```

## Arguments

- download_directory:

  The directory where the `.osm.pbf` and `.gpkg` files are saved.
  Default value is
  [`oe_download_directory()`](oe_download_directory.md).

- force:

  Internal option. It can be used to skip the checks run at the
  beginning of the function and force the removal of all `pbf`/`gpkg`
  files.

## Value

The same as [`unlink()`](https://rdrr.io/r/base/unlink.html).

## Examples

``` r
# Warning: the following removes all files in oe_download_directory()
if (FALSE) { # \dontrun{
oe_clean()} # }
```
