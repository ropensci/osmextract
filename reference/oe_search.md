# Search for a place and return an sf data frame locating it

This (only internal and experimental) function provides a simple
interface to the [nominatim](https://nominatim.openstreetmap.org)
service for finding the geographical location of place names.

## Usage

``` r
oe_search(
  place,
  base_url = "https://nominatim.openstreetmap.org",
  destfile = tempfile(fileext = ".geojson"),
  ...
)
```

## Arguments

- place:

  Text string containing the name of a place the location of which is to
  be found, such as `"Leeds"` or `"Milan"`.

- base_url:

  The URL of the nominatim server to use. The main open server hosted by
  OpenStreetMap is the default.

- destfile:

  The name of the destination file where the output of the search query,
  a `.geojson` file, should be saved.

- ...:

  Extra arguments that are passed to
  [`sf::st_read`](https://r-spatial.github.io/sf/reference/st_read.html).

## Value

An `sf` object corresponding to the input place. The `sf` object is read
by
[`sf::st_read()`](https://r-spatial.github.io/sf/reference/st_read.html)
and it is based on a `geojson` file returned by Nominatim API.
