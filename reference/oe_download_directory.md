# Returns the download directory used by the package

This function returns the download directory used the package. By
default, it is equal to the output of
`tools::R_user_dir("osmextract", "data")`. Such value can be overwritten
by setting the `OSMEXT_DOWNLOAD_DIRECTORY` environment variable. If the
directory does not exist, it will be created.

## Usage

``` r
oe_download_directory()
```

## Value

A character vector representing the path for the download directory used
by the package.

## Examples

``` r
oe_download_directory()
#> [1] "/home/runner/.local/share/R/osmextract"

if (requireNamespace("withr", quietly = TRUE)) {
  withr::with_envvar(
    c("OSMEXT_DOWNLOAD_DIRECTORY" = tempdir()),
    oe_download_directory()
  )
}
#> [1] "/tmp/RtmpwD1q4e"
```
