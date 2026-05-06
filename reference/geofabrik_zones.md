# An sf object of geographical zones taken from geofabrik.de

An `sf` object containing the URLs, names and file-sizes of the OSM
extracts stored at <https://download.geofabrik.de/>. You can read more
details about these data at the following link:
<https://download.geofabrik.de/technical.html>.

## Usage

``` r
geofabrik_zones
```

## Format

An sf object with 512 rows and 9 columns:

- id:

  A unique identifier. It contains letters, numbers and potentially the
  characters "-" and "/".

- name:

  The, usually English, long-form name of the area.

- parent:

  The identifier of the next larger excerpts that contains this one, if
  present.

- level:

  An integer code between 1 and 4. If level = 1, then the zone
  corresponds to one of the continents (Africa, Antarctica, Asia,
  Australia and Oceania, Central America, Europe, North America, and
  South America) or the Russian Federation. If level = 2, then the zone
  corresponds to the continent's subregions (i.e. the countries such as
  Italy, Great Britain, Spain, USA, Mexico, Belize, Morocco, Peru and so
  on). There are also some exceptions that correspond to the Special Sub
  Regions (according to the Geofabrik definition), which are: South
  Africa (includes Lesotho), Alps, Britain and Ireland, Germany +
  Austria + Switzerland, US Midwest, US Northeast, US Pacific, US South,
  US West, and all US states. Level = 3L corresponds to the subregions
  of each state (or each level 2 zone). For example, the West Yorkshire,
  which is a subregion of England, is a level 3 zone. Finally, level = 4
  correspond to the subregions of the third level and it is mainly
  related to some small areas in Germany. This field is used only for
  matching operations in case of spatial input.

- iso3166-1_alpha2:

  A character vector of two-letter [ISO3166-1
  codes](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2). This will be
  set on the smallest extract that still fully (or mostly) contains the
  entity with that code; e.g. the code "DE" will be given for the
  Germany extract and not for Europe even though Europe contains
  Germany. If an extract covers several countries and no per-country
  extracts are available (e.g. Israel and Palestine), then several ISO
  codes will be given (such as "PS IL" for "Palestine and Israel").

- iso3166_2:

  A character vector of usually five-character [ISO3166-2
  codes](https://en.wikipedia.org/wiki/ISO_3166-2). The same rules as
  above apply. Some entities have both an *iso3166-1* and *iso3166-2*
  code. For example, the *iso3166_2* code of each US State is "US - "
  plus the code of the state.

- pbf:

  Link to the latest `.osm.pbf` file for this region.

- pbf_file_size:

  Size of the `.pbf` file in bytes.

- geometry:

  The `sfg` for that geographical region. These are not the country
  boundaries, but a buffer around countries. Check
  [`oe_get_boundary()`](https://docs.ropensci.org/osmextract/reference/oe_get_boundary.md)
  to extract the geographical boundaries.

## Source

<https://download.geofabrik.de/>

## See also

Other provider's-database:
[`bbbike_zones`](https://docs.ropensci.org/osmextract/reference/bbbike_zones.md),
[`openstreetmap_fr_zones`](https://docs.ropensci.org/osmextract/reference/openstreetmap_fr_zones.md)
