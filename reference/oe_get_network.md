# Import transport networks used by a specific mode of transport

This function is a wrapper around
[`oe_get()`](https://docs.ropensci.org/osmextract/reference/oe_get.md)
and can be used to import a road network given a `place` and a mode of
transport. Check the Details for a precise description of the procedures
used to filter the OSM ways according to each each mode of transport.

## Usage

``` r
oe_get_network(
  place,
  mode = c("cycling", "driving", "walking"),
  ...,
  clean_output = FALSE,
  highway_filter = NULL
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
  [`oe_match()`](https://docs.ropensci.org/osmextract/reference/oe_match.md).

- mode:

  A character string of length one denoting the desired mode of
  transport. Can be abbreviated. Currently `cycling` (the default),
  `driving` and `walking` are supported.

- ...:

  Additional arguments passed to
  [`oe_get()`](https://docs.ropensci.org/osmextract/reference/oe_get.md)
  such as `boundary` or `force_download`.

- clean_output:

  logical; whether to standardise `oneway` values and simplify the
  `highway` values by removing the "\_link" suffix. Geometries of links
  where `oneway == -1` in the original data are reversed. If a
  `junction` column is present and its value is `"roundabout"`, the
  `oneway` attribute is automatically set to `"yes"`. Additionally, if a
  `highway_filter` is provided, only highways of the specified types are
  retained.

- highway_filter:

  Character vector of highway types to keep. Ignored if `clean_output`
  is `FALSE`. Valid values are: `"busway"`, `"cycleway"`, `"footway"`,
  `"living_street"`, `"motorway"`, `"path"`, `"pedestrian"`,
  `"primary"`, `"residential"`, `"rest_area"`, `"service"`,
  `"services"`, `"steps"`, `"tertiary"`, `"track"`, `"trunk"` and
  `"unclassified"`.

## Value

An `sf` object.

## Details

The definition of usable transport network was taken from the Python
packages
[osmnx](https://raw.githubusercontent.com/gboeing/osmnx/refs/heads/main/osmnx/_overpass.py)
and [pyrosm](https://pyrosm.readthedocs.io/en/latest/) and several other
documents found online, i.e.
<https://wiki.openstreetmap.org/wiki/OSM_tags_for_routing/Access_restrictions>,
<https://wiki.openstreetmap.org/wiki/Key:access>. See also the
discussion in <https://github.com/ropensci/osmextract/issues/153>.

The `cycling` mode of transport (i.e. the default value for `mode`
parameter) selects the OSM ways that meet the following conditions:

- The `highway` tag is not missing;

- The `highway` tag is not equal to `abandoned`, `bus_guideway`,
  `byway`, `construction`, `corridor`, `elevator`, `fixme`, `escalator`,
  `gallop`, `historic`, `no`, `planned`, `platform`, `proposed`,
  `raceway` or `steps`;

- The `highway` tag is not equal to `motorway`, `motorway_link`,
  `footway`, `bridleway` or `pedestrian` unless the tag `bicycle` is
  equal to `yes`, `designated`, `permissive` or `destination` (see
  [here](https://wiki.openstreetmap.org/wiki/Bicycle#Bicycle_Restrictions)
  for more details);

- The `access` tag is not equal to `private` or `no` unless `bicycle` is
  equal to `yes`, `permissive` or `designated` (see \#289);

- The `bicycle` tag is not equal to `no`, `use_sidepath`, `private`, or
  `restricted`;

- The `service` tag does not contain the string `private` (i.e.
  `private`, `private_access` and similar);

The `walking` mode of transport selects the OSM ways that meet the
following conditions:

- The `highway` tag is not missing;

- The `highway` tag is not equal to `abandoned`, `bus_guideway`,
  `byway`, `construction`, `corridor`, `elevator`, `fixme`, `escalator`,
  `gallop`, `historic`, `no`, `planned`, `platform`, `proposed`,
  `raceway`, `motorway` or `motorway_link`;

- The `highway` tag is not equal to `cycleway` unless the `foot` tag is
  equal to `yes`;

- The `access` tag is not equal to `private` or `no` unless `foot` is
  equal to `yes`, `permissive`, or `designated` (see \#289);

- The `foot` tag is not equal to `no`, `use_sidepath`, `private`, or
  `restricted`;

- The `service` tag does not contain the string `private` (i.e.
  `private`, `private_access` and similar).

The `driving` mode of transport selects the OSM ways that meet the
following conditions:

- The `highway` tag is not missing;

- The `highway` tag is not equal to `abandoned`, `bus_guideway`,
  `byway`, `construction`, `corridor`, `elevator`, `fixme`, `escalator`,
  `gallop`, `historic`, `no`, `planned`, `platform`, `proposed`,
  `cycleway`, `pedestrian`, `bridleway`, `path`, or `footway`;

- The `access` tag is not equal to `private` or `no` unless
  `motor_vehicle` is equal to `yes`, `permissive`, or `designated` (see
  \#289);

- The `service` tag does not contain the string `private` (i.e.
  `private`, `private_access` and similar).

Feel free to create a new issue in the [github
repo](https://github.com/ropensci/osmextract) if you want to suggest
modifications to the current filters or propose new values for
alternative modes of transport.

Starting from version 0.5.2, the `version` argument (see
[`oe_get()`](https://docs.ropensci.org/osmextract/reference/oe_get.md))
can be used to download historical OSM extracts from Geofabrik provider.

## See also

[`oe_get()`](https://docs.ropensci.org/osmextract/reference/oe_get.md)

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

# default value returned by OSM
its = oe_get(
  "ITS Leeds", quiet = TRUE, download_directory = tempdir()
)
plot(its["highway"], lwd = 2, key.pos = 4, key.width = lcm(2.75))

# walking mode of transport
its_walking = oe_get_network(
  "ITS Leeds", mode = "walking",
  download_directory = tempdir(), quiet = TRUE
)
plot(its_walking["highway"], lwd = 2, key.pos = 4, key.width = lcm(2.75))

# driving mode of transport
its_driving = oe_get_network(
  "ITS Leeds", mode = "driving",
  download_directory = tempdir(), quiet = TRUE
)
plot(its_driving["highway"], lwd = 2, key.pos = 4, key.width = lcm(2.75))


# Remove .pbf and .gpkg files in tempdir
oe_clean(tempdir())
```
