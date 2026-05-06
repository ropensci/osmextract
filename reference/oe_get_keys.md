# Return keys and (optionally) values stored in "other_tags" column

This function returns the OSM keys and (optionally) the values stored in
the `other_tags` field. See Details. In both cases, the keys are sorted
according to the number of occurrences, which means that the most common
keys are stored first.

## Usage

``` r
oe_get_keys(
  zone,
  layer = "lines",
  values = FALSE,
  which_keys = NULL,
  download_directory = oe_download_directory()
)

# Default S3 method
oe_get_keys(
  zone,
  layer = "lines",
  values = FALSE,
  which_keys = NULL,
  download_directory = oe_download_directory()
)

# S3 method for class 'character'
oe_get_keys(
  zone,
  layer = "lines",
  values = FALSE,
  which_keys = NULL,
  download_directory = oe_download_directory()
)

# S3 method for class 'sf'
oe_get_keys(
  zone,
  layer = "lines",
  values = FALSE,
  which_keys = NULL,
  download_directory = oe_download_directory()
)

# S3 method for class 'oe_key_values_list'
print(x, n = getOption("oe_max_print_keys", 10L), ...)
```

## Arguments

- zone:

  An `sf` object with an `other_tags` field or a character vector (of
  length 1) that can be linked to or pointing to a `.osm.pbf` or `.gpkg`
  file with an `other_tags` field. Character vectors are linked to
  `.osm.pbf` files using [`oe_find()`](oe_find.md).

- layer:

  Which `layer` should be read in? Typically `points`, `lines` (the
  default), `multilinestrings`, `multipolygons` or `other_relations`. If
  you specify an ad-hoc query using the argument `query` (see
  introductory vignette and examples), then [`oe_get()`](oe_get.md) and
  [`oe_read()`](oe_read.md) will read the layer specified in the query
  and ignore `layer` argument. See also
  [\#122](https://github.com/ropensci/osmextract/issues/122).

- values:

  Logical. If `TRUE`, then function returns the keys and the
  corresponding values, otherwise only the keys. Defaults to `FALSE. `

- which_keys:

  Character vector used to subset only some keys and corresponding
  values. Ignored if `values` is `FALSE`. See examples.

- download_directory:

  Path of the directory that stores the `.osm.pbf` files. Only relevant
  when `zone` is as a character vector that must be matched to a file
  via [`oe_find()`](oe_find.md). Ignored unless `zone` is a character
  vector.

- x:

  object of class `oe_key_values_list`

- n:

  Maximum number of keys (and corresponding values) to print; can be set
  globally by `options(oe_max_print_keys=...)`. Default value is 10.

- ...:

  Ignored.

## Value

If the argument `values` is `FALSE` (the default), then the function
returns a character vector with the names of all keys stored in the
`other_tags` field. If `values` is `TRUE`, then the function returns
named list which stores all keys and the corresponding values. In the
latter case, the returned object has class `oe_key_values_list` and we
defined an ad-hoc printing method. See Details.

## Details

OSM data are typically documented using several
[`tags`](https://wiki.openstreetmap.org/wiki/Tags), i.e. pairs of two
items, namely a `key` and a `value`. The conversion between `.osm.pbf`
and `.gpkg` formats is governed by a `CONFIG` file that lists which tags
must be explicitly added to the `.gpkg` file. All the other keys are
automatically stored using an `other_tags` field with a syntax
compatible with the PostgreSQL HSTORE type. See
[here](https://gdal.org/en/stable/drivers/vector/osm.html#driver-capabilities)
for more details.

When the argument `values` is `TRUE`, then the function returns a named
list of class `oe_key_values_list` that, for each key, summarises the
corresponding values. The key-value pairs are stored using the following
format:
`list(key1 = c("value1", "value1", "value2", ...), key2 = c("value1", ...) ...)`.
We decided to implement an ad-hoc method for printing objects of class
`oe_key_values_list` using the following structure:

    key1 = {#value1 = n1; #value2 = n2; #value3 = n3,
      ...} key2 = {#value1 = n1; #value2 = n2; ...} key3 = {#value1 = n1} ...

where `n1` denotes the number of times that value1 is repeated, `n2`
denotes the number of times that value2 is repeated and so on. Also the
values are listed according to the number of occurrences in decreasing
order. By default, the function prints only the ten most common keys,
but the number can be adjusted using the option `oe_max_print_keys`.

Finally, the `hstore_get_value()` function can be used inside the
`query` argument in [`oe_get()`](oe_get.md) to extract one particular
tag from an existing file. Check the introductory vignette and see
examples.

## See also

[`oe_vectortranslate()`](oe_vectortranslate.md)

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

# Get keys
oe_get_keys("ITS Leeds", download_directory = tempdir())
#>  [1] "surface"             "lanes"               "bicycle"            
#>  [4] "lit"                 "access"              "oneway"             
#>  [7] "maxspeed"            "ref"                 "foot"               
#> [10] "natural"             "lanes:backward"      "lanes:forward"      
#> [13] "source:name"         "step_count"          "lanes:psv:backward" 
#> [16] "alt_name"            "layer"               "motor_vehicle"      
#> [19] "tunnel"              "bridge"              "covered"            
#> [22] "incline"             "lanes:psv"           "service"            
#> [25] "turn:lanes"          "turn:lanes:forward"  "frequency"          
#> [28] "indoor"              "lcn"                 "level"              
#> [31] "maxheight"           "operator"            "power"              
#> [34] "source:geometry"     "substation"          "turn:lanes:backward"
#> [37] "voltage"             "website"            

# Get keys and values
oe_get_keys("ITS Leeds", values = TRUE, download_directory = tempdir())
#> Found 38 unique keys, printed in ascending order of % NA values. The first 10 keys are: 
#> surface (91% NAs) = {#asphalt = 12; #paved = 3; #cobblestone = 1; #paving_sto...}
#> lanes (91% NAs) = {#2 = 9; #1 = 7}
#> bicycle (92% NAs) = {#yes = 10; #designated = 5}
#> lit (92% NAs) = {#yes = 15}
#> access (92% NAs) = {#permissive = 12; #yes = 2}
#> oneway (93% NAs) = {#yes = 13}
#> maxspeed (93% NAs) = {#30 mph = 12}
#> ref (94% NAs) = {#A660 = 9; #4184 = 1}
#> foot (95% NAs) = {#yes = 5; #designated = 4}
#> natural (96% NAs) = {#tree_row = 7}
#> [Truncated output...]

# Subset some keys
oe_get_keys(
  "ITS Leeds", values = TRUE, which_keys = c("surface", "lanes"),
  download_directory = tempdir()
)
#> Found 2 unique keys, printed in ascending order of % NA values. 
#> surface (91% NAs) = {#asphalt = 12; #paved = 3; #cobblestone = 1; #paving_sto...}
#> lanes (91% NAs) = {#2 = 9; #1 = 7}

# Print all (non-NA) values for a given set of keys
res = oe_get_keys("ITS Leeds", values = TRUE, download_directory = tempdir())
res["surface"]
#> $surface
#>  [1] "asphalt"       "asphalt"       "asphalt"       "asphalt"      
#>  [5] "asphalt"       "asphalt"       "paved"         "cobblestone"  
#>  [9] "asphalt"       "asphalt"       "paved"         "paved"        
#> [13] "paving_stones" "asphalt"       "asphalt"       "asphalt"      
#> [17] "asphalt"      
#> 

# Get keys from an existing sf object
its = oe_get("ITS Leeds", download_directory = tempdir())
#> The input place was matched with: ITS Leeds
#> The chosen file was already detected in the download directory. Skip downloading.
#> Starting with the vectortranslate operations on the input file!
#> 0...10...20...30...40...50...60...70...80...90...100 - done.
#> Finished the vectortranslate operations on the input file!
#> Reading layer `lines' from data source `/tmp/RtmpQk2KqP/test_its-example.gpkg' using driver `GPKG'
#> Simple feature collection with 189 features and 10 fields
#> Geometry type: LINESTRING
#> Dimension:     XY
#> Bounding box:  xmin: -1.562458 ymin: 53.80471 xmax: -1.548076 ymax: 53.81105
#> Geodetic CRS:  WGS 84
oe_get_keys(its, values = TRUE)
#> Found 38 unique keys, printed in ascending order of % NA values. The first 10 keys are: 
#> surface (91% NAs) = {#asphalt = 12; #paved = 3; #cobblestone = 1; #paving_sto...}
#> lanes (91% NAs) = {#2 = 9; #1 = 7}
#> bicycle (92% NAs) = {#yes = 10; #designated = 5}
#> lit (92% NAs) = {#yes = 15}
#> access (92% NAs) = {#permissive = 12; #yes = 2}
#> oneway (93% NAs) = {#yes = 13}
#> maxspeed (93% NAs) = {#30 mph = 12}
#> ref (94% NAs) = {#A660 = 9; #4184 = 1}
#> foot (95% NAs) = {#yes = 5; #designated = 4}
#> natural (96% NAs) = {#tree_row = 7}
#> [Truncated output...]

# Get keys from a character vector pointing to a file (might be faster than
# reading the complete file and then filter it)
its_path = oe_get(
  "ITS Leeds", download_only = TRUE,
  download_directory = tempdir(), quiet = TRUE
)
oe_get_keys(its_path, values = TRUE)
#> Found 38 unique keys, printed in ascending order of % NA values. The first 10 keys are: 
#> surface (91% NAs) = {#asphalt = 12; #paved = 3; #cobblestone = 1; #paving_sto...}
#> lanes (91% NAs) = {#2 = 9; #1 = 7}
#> bicycle (92% NAs) = {#yes = 10; #designated = 5}
#> lit (92% NAs) = {#yes = 15}
#> access (92% NAs) = {#permissive = 12; #yes = 2}
#> oneway (93% NAs) = {#yes = 13}
#> maxspeed (93% NAs) = {#30 mph = 12}
#> ref (94% NAs) = {#A660 = 9; #4184 = 1}
#> foot (95% NAs) = {#yes = 5; #designated = 4}
#> natural (96% NAs) = {#tree_row = 7}
#> [Truncated output...]

# Add a key to an existing .gpkg file without repeating the
# vectortranslate operations
its = oe_get("ITS Leeds", download_directory = tempdir())
#> The input place was matched with: ITS Leeds
#> The chosen file was already detected in the download directory. Skip downloading.
#> The corresponding gpkg file was already detected. Skip vectortranslate operations.
#> Reading layer `lines' from data source `/tmp/RtmpQk2KqP/test_its-example.gpkg' using driver `GPKG'
#> Simple feature collection with 189 features and 10 fields
#> Geometry type: LINESTRING
#> Dimension:     XY
#> Bounding box:  xmin: -1.562458 ymin: 53.80471 xmax: -1.548076 ymax: 53.81105
#> Geodetic CRS:  WGS 84
colnames(its)
#>  [1] "osm_id"     "name"       "highway"    "waterway"   "aerialway" 
#>  [6] "barrier"    "man_made"   "railway"    "z_order"    "other_tags"
#> [11] "geometry"  
its_extra = oe_read(
  its_path,
  query = "SELECT *, hstore_get_value(other_tags, 'oneway') AS oneway FROM lines",
  quiet = TRUE
)
colnames(its_extra)
#>  [1] "osm_id"     "name"       "highway"    "waterway"   "aerialway" 
#>  [6] "barrier"    "man_made"   "railway"    "z_order"    "other_tags"
#> [11] "oneway"     "geometry"  

# The following fails since there is no points layer in the .gpkg file
if (FALSE) { # \dontrun{
oe_get_keys(its_path, layer = "points")} # }

# Add layer and read keys
its_path = oe_get(
  "ITS Leeds", layer = "points", download_only = TRUE,
  download_directory = tempdir(), quiet = TRUE
)
oe_get_keys(its_path, layer = "points")
#>  [1] "amenity"                 "addr:postcode"          
#>  [3] "addr:street"             "addr:city"              
#>  [5] "fhrs:id"                 "capacity"               
#>  [7] "covered"                 "addr:housenumber"       
#>  [9] "operator"                "bicycle_parking"        
#> [11] "addr:suburb"             "natural"                
#> [13] "shop"                    "crossing"               
#> [15] "naptan:AtcoCode"         "naptan:Bearing"         
#> [17] "naptan:CommonName"       "naptan:PlusbusZoneRef"  
#> [19] "naptan:ShortCommonName"  "naptan:Street"          
#> [21] "naptan:verified"         "addr:housename"         
#> [23] "bus"                     "collection_times"       
#> [25] "local_ref"               "naptan:Crossing"        
#> [27] "naptan:Indicator"        "naptan:Landmark"        
#> [29] "public_transport"        "condition"              
#> [31] "entrance"                "ref:UK:leedscc:bin"     
#> [33] "shelter"                 "waste_basket:model"     
#> [35] "crossing_ref"            "wheelchair"             
#> [37] "brand"                   "brand:wikidata"         
#> [39] "brand:wikipedia"         "noexit"                 
#> [41] "booth"                   "old_name"               
#> [43] "opening_hours"           "advertising"            
#> [45] "foot"                    "kerb"                   
#> [47] "post_box:type"           "tactile_paving"         
#> [49] "takeaway"                "toilets:wheelchair"     
#> [51] "addr:unit"               "cuisine"                
#> [53] "level"                   "naptan:Notes"           
#> [55] "royal_cypher"            "source:addr"            
#> [57] "timetable"               "tourism"                
#> [59] "website"                 "access"                 
#> [61] "addr:source"             "artist_name"            
#> [63] "artwork_type"            "atm"                    
#> [65] "bicycle"                 "building"               
#> [67] "contact:website"         "direction"              
#> [69] "fee"                     "healthcare"             
#> [71] "historic"                "horse"                  
#> [73] "live_display"            "loc_name"               
#> [75] "material"                "motor_vehicle"          
#> [77] "naptan:BusStopType"      "not:addr:postcode"      
#> [79] "phone"                   "post_box:design"        
#> [81] "recycling:glass_bottles" "recycling:paper"        
#> [83] "traffic_signals"         "url"                    
#> [85] "wikidata"               

# Remove .pbf and .gpkg files in tempdir
rm(its_pbf, res, its_path, its, its_extra)
oe_clean(tempdir())
```
