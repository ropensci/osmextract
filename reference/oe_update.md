# Update all the .osm.pbf files saved in a directory

This function is used to re-download all `.osm.pbf` files stored in
`download_directory` that were firstly downloaded through
[`oe_get()`](https://docs.ropensci.org/osmextract/reference/oe_get.md).
See Details.

## Usage

``` r
oe_update(
  download_directory = oe_download_directory(),
  quiet = FALSE,
  delete_gpkg = TRUE,
  max_file_size = 5e+08,
  ...
)
```

## Arguments

- download_directory:

  Character string of the path of the directory where the `.osm.pbf`
  files are saved.

- quiet:

  Boolean. If `FALSE` the function prints informative messages. See
  Details.

- delete_gpkg:

  Boolean. if `TRUE` the function deletes the old `.gpkg` files. We
  added this parameter to minimize the probability of accidentally
  reading-in old and not-synchronized `.gpkg` files. See Details.
  Defaults to `TRUE`.

- max_file_size:

  The maximum file size to download without asking in interactive mode.
  Default: `5e+8`, half a gigabyte.

- ...:

  Additional parameter that will be passed to
  [`oe_get()`](https://docs.ropensci.org/osmextract/reference/oe_get.md)
  (such as `stringsAsFactors` or `query`).

## Value

The path(s) of the `.osm.pbf` file(s) that were updated.

## Details

This function is used to re-download `.osm.pbf` files that are stored in
a directory (specified by `download_directory` param) and that were
firstly downloaded through
[`oe_get()`](https://docs.ropensci.org/osmextract/reference/oe_get.md) .
The name of the files must begin with the name of one of the supported
providers (see
[`oe_providers()`](https://docs.ropensci.org/osmextract/reference/oe_providers.md))
and it must end with `.osm.pbf`. All other files in the directory that
do not match this format are ignored.

The process for re-downloading the `.osm.pbf` files is performed using
the function
[`oe_get()`](https://docs.ropensci.org/osmextract/reference/oe_get.md) .
The appropriate provider is determined by looking at the first word in
the path of the `.osm.pbf` file. The place is determined by looking at
the second word in the file path and the matching is performed through
the `id` column in the provider's database. So, for example, the path
`geofabrik_italy-latest-update.osm.pbf` will be matched with the
provider `"geofabrik"` and the geographical zone `italy` through the
column `id` in `geofabrik_zones`.

The parameter `delete_gpkg` is used to delete all `.gpkg` files in
`download_directory`. We decided to set its default value to `TRUE` to
minimize the possibility of reading-in old and non-synchronized `.gpkg`
files. If you set `delete_gpkg = FALSE`, then you need to manually
reconvert all files using
[`oe_get()`](https://docs.ropensci.org/osmextract/reference/oe_get.md)
or
[`oe_vectortranslate()`](https://docs.ropensci.org/osmextract/reference/oe_vectortranslate.md)
.

If you set the parameter `quiet` to `FALSE`, then the function will
print some useful messages regarding the characteristics of the files
before and after updating them. More precisely, it will print the output
of the columns `size`, `mtime` and `ctime` from
[`file.info()`](https://rdrr.io/r/base/file.info.html). Please note that
the meaning of `mtime` and `ctime` depends on the OS and the file
system. Check [`file.info()`](https://rdrr.io/r/base/file.info.html).

## Examples

``` r
if (FALSE) { # \dontrun{
# Set up a fake directory with .pbf and .gpkg files
fake_dir = tempdir()
# Fill the directory
oe_get("Andorra", download_directory = fake_dir, download_only = TRUE)
# Check the directory
list.files(fake_dir, pattern = "gpkg|pbf")
# Update all .pbf files and delete all .gpkg files
oe_update(fake_dir, quiet = TRUE)
list.files(fake_dir, pattern = "gpkg|pbf")} # }
```
