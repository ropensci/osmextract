# Match input place with a url

This function is used to match an input `place` with the URL of a
`.osm.pbf` file (and its file-size, if present). The URLs are stored in
several provider's databases. See [`oe_providers()`](oe_providers.md)
and examples.

## Usage

``` r
oe_match(place, ...)

# Default S3 method
oe_match(place, ...)

# S3 method for class 'bbox'
oe_match(place, ...)

# S3 method for class 'sf'
oe_match(place, ...)

# S3 method for class 'sfc'
oe_match(
  place,
  provider = "geofabrik",
  level = NULL,
  version = "latest",
  quiet = FALSE,
  ...
)

# S3 method for class 'numeric'
oe_match(place, provider = "geofabrik", quiet = FALSE, ...)

# S3 method for class 'character'
oe_match(
  place,
  provider = "geofabrik",
  quiet = FALSE,
  match_by = "name",
  max_string_dist = 1,
  version = "latest",
  ...
)
```

## Arguments

- place:

  Description of the geographical area that should be matched with a
  `.osm.pbf` file. Can be either a length-1 character vector, an
  `sf`/`sfc`/`bbox` object with any CRS, or a numeric vector of
  coordinates with length 2. In the last case, it is assumed that the
  EPSG code is 4326 specified as c(LON, LAT), while you can use any CRS
  with `sf`/`sfc`/`bbox` objects. See Details and Examples in
  `oe_match()`.

- ...:

  arguments passed to other methods

- provider:

  Which provider should be used to download the data? Available
  providers can be browsed with [`oe_providers()`](oe_providers.md). For
  [`oe_get()`](oe_get.md) and `oe_match()`, if `place` is equal to
  `ITS Leeds`, then `provider` is internally set equal to `"test"`. This
  is just for simple examples and internal tests.

- level:

  An integer representing the desired hierarchical level in case of
  spatial matching. For the `geofabrik` provider, for example, `1`
  corresponds with continent-level datasets, `2` for countries, `3`
  corresponds to regions and `4` to subregions. Hence, we could
  approximately say that smaller administrative units correspond to
  bigger levels. If `NULL`, the default, the `oe_*` functions will
  select the highest available level. See Details and Examples in
  `oe_match()`.

- version:

  The version of the OSM extract to download. The default is "latest".
  Other possible values are typically specified using the format YYMMDD
  (e.g. "200101"). The complete list of all available historic files for
  a given extract can be browsed from the Geofabrik website (e.g.
  <https://download.geofabrik.de/europe/italy.html> and then click on
  'raw directory index'). Note: the geographical coverage of an extract
  may change over time. For example, recent (2021+) extracts for
  Barcelona are at the regional level (cataluna), while older
  (2012-2021) extracts are at the national level (spain). This means
  that downloading historical data for a place like Barcelona may
  require changing the `place` argument to "spain" for older versions.

- quiet:

  Boolean. If `FALSE`, the function prints informative messages.
  Starting from `sf` version
  [0.9.6](https://r-spatial.github.io/sf/news/index.html#version-0-9-6-2020-09-13),
  if `quiet` is equal to `FALSE`, then vectortranslate operations will
  display a progress bar.

- match_by:

  Which column of the provider's database should be used for matching
  the input `place` with a `.osm.pbf` file? The default is `"name"`.
  Check Details and Examples in `oe_match()` to understand how this
  parameter works. Ignored when `place` is not a character vector since,
  in that case, the matching is performed through a spatial operation.

- max_string_dist:

  Numerical value greater or equal than 0. What is the maximum distance
  in fuzzy matching (i.e. Approximate String Distance, see
  [`adist()`](https://rdrr.io/r/utils/adist.html)) between input `place`
  and `match_by` column that can be tolerated before testing alternative
  providers or looking for geographical matching with Nominatim API?
  This parameter is set equal to 0 if `match_by` is equal to
  `iso3166_1_alpha2` or `iso3166_2`. Check Details and Examples in
  `oe_match()` to understand why this parameter is important. Ignored
  when `place` is not a character vector since, in that case, the
  matching is performed through a spatial operation.

## Value

A list with two elements, named `url` and `file_size`. The first element
is the URL of the `.osm.pbf` file associated with the input `place`,
while the second element is the size of the file in bytes (which may be
`NULL` or `NA`)

## Details

If the input place is specified as a spatial object (either `sf` or
`sfc`), then the function will return a geographical area that
completely contains the object (or an error). The argument `level`
(which must be specified as an integer between 1 and 4, extreme values
included) is used to select between multiple geographically nested
areas. We could roughly say that smaller administrative units correspond
to higher levels. Check the help page of the chosen provider for more
details on `level` field. By default, `level = NULL`, which means that
`oe_match()` will return the area corresponding to the highest available
level. If there is no geographical area at the desired level, then the
function will return an error. If there are multiple areas at the same
`level` intersecting the input place, then the function will return the
area whose centroid is closest to the input place.

If the input place is specified as a character vector and there are
multiple plausible matches between the input place and the `match_by`
column, then the function will return a warning and it will select the
first match. See Examples. On the other hand, if the approximate string
distance between the input `place` and the best match in `match_by`
column is greater than `max_string_dist`, then the function will look
for exact matches (i.e. `max_string_dist = 0`) in the other supported
providers. If it finds an exact match, then it will return the
corresponding URL. Otherwise, if `match_by` is equal to `"name"`, then
it will try to geolocate the input `place` using the [Nominatim
API](https://nominatim.org/release-docs/develop/api/Overview/), and then
it will perform a spatial matching operation (see Examples and
introductory vignette), while, if `match_by != "name"`, then it will
return an error.

The fields `iso3166_1_alpha2` and `iso3166_2` are used by Geofabrik
provider to perform matching operations using [ISO 3166-1
alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) and [ISO
3166-2](https://en.wikipedia.org/wiki/ISO_3166-2) codes. See
[geofabrik_zones](geofabrik_zones.md) for more details.

## See also

[`oe_providers()`](oe_providers.md) and
[`oe_match_pattern()`](oe_match_pattern.md).

## Examples

``` r
# The simplest example:
oe_match("Italy")
#> The input place was matched with: Italy
#> $url
#> [1] "https://download.geofabrik.de/europe/italy-latest.osm.pbf"
#> 
#> $file_size
#> [1] 2e+09
#> 

# The default provider is "geofabrik", but we can change that:
oe_match("Leeds", provider = "bbbike")
#> The input place was matched with: Leeds
#> $url
#> [1] "https://download.bbbike.org/osm/bbbike/Leeds/Leeds.osm.pbf"
#> 
#> $file_size
#> [1] 38177699
#> 

# By default, the matching operations are performed through the column
# "name" in the provider's database but this can be a problem. Hence,
# you can perform the matching operations using other columns:
oe_match("RU", match_by = "iso3166_1_alpha2")
#> The input place was matched with: RU
#> $url
#> [1] "https://download.geofabrik.de/russia-latest.osm.pbf"
#> 
#> $file_size
#> [1] 4080218931
#> 
# Run oe_providers() for reading a short description of all providers and
# check the help pages of the corresponding databases to learn which fields
# are present.

# You can always increase the max_string_dist argument, but it can be
# dangerous:
oe_match("London", max_string_dist = 3, quiet = FALSE)
#> The input place was matched with: Jordan
#> $url
#> [1] "https://download.geofabrik.de/asia/jordan-latest.osm.pbf"
#> 
#> $file_size
#> [1] 2.9e+07
#> 

# Match the input zone using an sfc object:
milan_duomo = sf::st_sfc(sf::st_point(c(1514924, 5034552)), crs = 3003)
oe_match(milan_duomo, quiet = FALSE)
#> The input place was matched with Nord-Ovest. 
#> $url
#> [1] "https://download.geofabrik.de/europe/italy/nord-ovest-latest.osm.pbf"
#> 
#> $file_size
#> [1] 5.48e+08
#> 
leeds = sf::st_sfc(sf::st_point(c(430147.8, 433551.5)), crs = 27700)
oe_match(leeds, provider = "bbbike")
#> The input place was matched with Leeds. 
#> $url
#> [1] "https://download.bbbike.org/osm/bbbike/Leeds/Leeds.osm.pbf"
#> 
#> $file_size
#> [1] 38177699
#> 

# If you specify more than one sfg object, then oe_match will select the OSM
# extract that covers all areas
milan_leeds = sf::st_sfc(
  sf::st_point(c(9.190544, 45.46416)), # Milan
  sf::st_point(c(-1.543789, 53.7974)), # Leeds
  crs = 4326
)
oe_match(milan_leeds)
#> The input place was matched with Europe. 
#> $url
#> [1] "https://download.geofabrik.de/europe-latest.osm.pbf"
#> 
#> $file_size
#> [1] 34144990003
#> 

# Match the input zone using a numeric vector of coordinates
# (in which case crs = 4326 is assumed)
oe_match(c(9.1916, 45.4650)) # Milan, Duomo using CRS = 4326
#> The input place was matched with Nord-Ovest. 
#> $url
#> [1] "https://download.geofabrik.de/europe/italy/nord-ovest-latest.osm.pbf"
#> 
#> $file_size
#> [1] 5.48e+08
#> 

# The following returns a warning since Berin is matched both
# with Benin and Berlin
oe_match("Berin", quiet = FALSE)
#> The input place was matched with: Benin
#> $url
#> [1] "https://download.geofabrik.de/africa/benin-latest.osm.pbf"
#> 
#> $file_size
#> [1] 4.5e+07
#> 

# If the input place does not match any zone in the chosen provider, then the
# function will test the other providers:
oe_match("Leeds")
#> No exact match found for place = Leeds and provider = geofabrik. Best match is Laos. 
#> Checking the other providers...
#> An exact string match was found using provider = bbbike.
#> $url
#> [1] "https://download.bbbike.org/osm/bbbike/Leeds/Leeds.osm.pbf"
#> 
#> $file_size
#> [1] 38177699
#> 

# If the input place cannot be exactly matched with any zone in any provider,
# then the function will try to geolocate the input and then it will perform a
# spatial match:
if (FALSE) { # \dontrun{
oe_match("Milan")} # }

# The level parameter can be used to select smaller or bigger geographical
# areas during spatial matching
yak = c(-120.51084, 46.60156)
if (FALSE) { # \dontrun{
oe_match(yak, level = 3) # error
oe_match(yak, level = 2) # by default, level is equal to the maximum value
oe_match(yak, level = 1)} # }
```
