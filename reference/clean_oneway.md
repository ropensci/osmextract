# Clean the oneway values in a OSM network

This helper function standardises the oneway values in a OSM network. It
also applies a few implied `oneway` tag restriction based on the
`junction` tag values if specified and substitutes remaining `NA` values
as `"no"`. See Details.

## Usage

``` r
clean_oneway(x, quiet = FALSE)
```

## Arguments

- x:

  a `sf` object representing a spatial network with the `oneway` and
  `junction` columns

- quiet:

  logical, whether to suppress messages. Default is `FALSE`.

## Value

An `sf` object with standardised oneway values

## Details

According to the information reported at
[wiki.openstreetmap.org](https://wiki.openstreetmap.org/wiki/Key:oneway#Implied_oneway_restriction),
the `oneway` key can only assume one out of 5 possible values: `"yes"`,
`"no"`, `"-1"`, `"reversible"`, and `"alternating"`. However, the oneway
tag is optional and typically missing. Hence, the objective of this
function is to replace the `NA` values whenever possible using
contextual information.

In fact, there are tags or combination of tags (such as
junction='roundabout') which imply `oneway='yes'`. This function tests
such combination and converts the NA values into 'yes'.

Then, the `oneway='-1'` values (which indicate wrong-way roads) are
fixed by reversing the geometry of the lines and setting the road as
oneway.

Finally, the remaining NA values are set as `oneway='no'`. For
simplicity, even the `oneway='reversible'` and `oneway='alternating'`
are converted into `oneway='no'`.

## Examples

``` r
# Copy the ITS file to tempdir() to make sure that the examples do not
# require internet connection. You can skip the next 4 lines (and start
# directly with oe_get_keys) when running the examples locally.
its_pbf = file.path(tempdir(), "test_its-example.osm.pbf")
file.copy(
  from = system.file("its-example.osm.pbf", package = "osmextract"),
  to = its_pbf,
  overwrite = TRUE
)
#> [1] TRUE
roads <- oe_get_network(
  place = "ITS Leeds",
  mode = "driving",
  download_directory = tempdir(),
  quiet = TRUE
)
table(roads$oneway, useNA = "ifany")
#> 
#>  yes <NA> 
#>   13   80 
roads_clean <- clean_oneway(roads)
table(roads_clean$oneway, useNA = "ifany")
#> 
#>  no yes 
#>  80  13 
```
