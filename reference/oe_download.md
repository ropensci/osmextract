# Download a file given a url

This function is used to download a file given a URL. It focuses on OSM
extracts with `.osm.pbf` format stored by one of the providers
implemented in the package. The URL is specified through the parameter
`file_url`.

## Usage

``` r
oe_download(
  file_url,
  provider = NULL,
  file_basename = basename(file_url),
  download_directory = oe_download_directory(),
  file_size = NA,
  force_download = FALSE,
  max_file_size = 5e+08,
  quiet = FALSE
)
```

## Arguments

- file_url:

  A URL pointing to a (typically `.osm.pbf`) file.

- provider:

  Which provider stores the file? If `NULL` (the default), the function
  tries to infer it. It must be specified for non-standard cases. See
  details and examples.

- file_basename:

  The basename of the file. The default behaviour is to auto-generate it
  from the URL using
  [`basename()`](https://rdrr.io/r/base/basename.html).

- download_directory:

  Directory to store the file containing OSM data?.

- file_size:

  How big is the file? Optional. `NA` by default. If it's bigger than
  `max_file_size` and the function is run in interactive mode, then an
  interactive menu is displayed, asking for permission for downloading
  the file.

- force_download:

  Should the `.osm.pbf` file be updated even if it has already been
  downloaded? `FALSE` by default. This parameter is used to update old
  `.osm.pbf` files.

- max_file_size:

  The maximum file size to download without asking in interactive mode.
  Default: `5e+8`, half a gigabyte.

- quiet:

  Boolean. If `FALSE`, the function prints informative messages.
  Starting from `sf` version
  [0.9.6](https://r-spatial.github.io/sf/news/index.html#version-0-9-6-2020-09-13),
  if `quiet` is equal to `FALSE`, then vectortranslate operations will
  display a progress bar.

## Value

A character string representing the file's path.

## Details

This function runs several checks before actually downloading a new file
to avoid overloading the OSM providers. The first step is the definition
of the file path associated to the input `file_url`. The path is created
by pasting together the `download_directory`, the name of chosen
provider (which may be inferred from the URL), and the `basename` of the
URL. For example, if `file_url` is equal to
`"https://download.geofabrik.de/europe/italy-latest.osm.pbf"`, and
`download_directory = "/tmp"`, then the path is built as
`"/tmp/geofabrik_italy-latest.osm.pbf"`. If this file already exists,
the function just returns its path. The parameter `force_download` can
be used to modify this behaviour. If there is no file associated with
the new path, the function downloads it using
[`httr::GET()`](https://httr.r-lib.org/reference/GET.html). The timeout
for the download can be modified using `options("timeout")`. The default
value is 300s.

## Examples

``` r
(its_match = oe_match("ITS Leeds", quiet = TRUE))
#> $url
#> [1] "https://github.com/ropensci/osmextract/raw/master/inst/its-example.osm.pbf"
#> 
#> $file_size
#> [1] 40792
#> 

if (FALSE) { # \dontrun{
oe_download(
  file_url = its_match$url,
  file_size = its_match$file_size,
  provider = "test",
  download_directory = tempdir()
)
iow_url = oe_match("Isle of Wight")
oe_download(
  file_url = iow_url$url,
  file_size = iow_url$file_size,
  download_directory = tempdir()
)
Sucre_url = oe_match("Sucre", provider = "bbbike")
oe_download(
  file_url = Sucre_url$url,
  file_size = Sucre_url$file_size,
  download_directory = tempdir()
)} # }
```
