# Check patterns in the provider's databases

This function is used to explore all provider's databases and look for
matches. This function can be useful in combination with
[`oe_match()`](https://docs.ropensci.org/osmextract/reference/oe_match.md)
and
[`oe_get()`](https://docs.ropensci.org/osmextract/reference/oe_get.md)
for an exploratory analysis and an easy match. See Examples.

## Usage

``` r
oe_match_pattern(pattern, ...)

# S3 method for class 'numeric'
oe_match_pattern(pattern, full_row = FALSE, ...)

# S3 method for class 'sf'
oe_match_pattern(pattern, full_row = FALSE, ...)

# S3 method for class 'bbox'
oe_match_pattern(pattern, full_row = FALSE, ...)

# S3 method for class 'sfc'
oe_match_pattern(pattern, full_row = FALSE, ...)

# S3 method for class 'character'
oe_match_pattern(pattern, match_by = "name", full_row = FALSE, ...)
```

## Arguments

- pattern:

  Description of the pattern. Can be either a length-1 character vector,
  an `sf`/`sfc`/`bbox` object, or a numeric vector of coordinates with
  length 2. In the last case, it is assumed that the EPSG code is 4326
  specified as c(LON, LAT), while you can use any CRS with
  `sf`/`sfc`/`bbox` objects.

- ...:

  arguments passed to other methods

- full_row:

  Boolean. Return all columns for the matching rows? `FALSE` by default.

- match_by:

  Name of the column in the provider's database that will be used to
  find the match in case of character input. In all the other cases, the
  match is performed using a spatial overlay operation and the output
  returns the values stored in the `name` column (or even the full `sf`
  object when `full_row` is `TRUE`).

## Value

A list of character vectors or `sf` objects (according to the value of
the parameter `full_row`). If no OSM zone can be matched with the input
string, then the function returns an empty list.

## Examples

``` r
oe_match_pattern("Yorkshire")
#> $geofabrik
#> [1] "East Yorkshire with Hull" "North Yorkshire"         
#> [3] "South Yorkshire"          "West Yorkshire"          
#> 
#> $openstreetmap_fr
#> [1] "Yorkshire And The Humber"
#> 

res = oe_match_pattern("Yorkshire", full_row = TRUE)
lapply(res, function(x) sf::st_drop_geometry(x)[, 1:3])
#> $geofabrik
#>                           id                     name  parent
#> 110 east-yorkshire-with-hull East Yorkshire with Hull england
#> 299          north-yorkshire          North Yorkshire england
#> 383          south-yorkshire          South Yorkshire england
#> 498           west-yorkshire           West Yorkshire england
#> 
#> $openstreetmap_fr
#>                           id                     name  parent
#> 752 yorkshire_and_the_humber Yorkshire And The Humber england
#> 

oe_match_pattern(c(9, 45)) # long/lat for Milan, Italy
#> $geofabrik
#> [1] "Europe"     "Italy"      "Nord-Ovest"
#> 
#> $openstreetmap_fr
#> [1] "Europe"    "Italy"     "Lombardia"
#> 
```
