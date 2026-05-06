# An sf object of geographical zones taken from bbbike.org

Start bicycle routing for... everywhere!

## Usage

``` r
bbbike_zones
```

## Format

An `sf` object with 238 rows and 6 columns:

- name:

  The, usually English, long-form name of the city.

- pbf:

  Link to the latest `.osm.pbf` file for this region.

- pbf_file_size:

  Size of the pbf file in bytes.

- id:

  A unique identifier. It contains letters, numbers and potentially the
  characters "-" and "/".

- level:

  An integer code always equal to 3 (since the bbbike data represent
  non-hierarchical geographical zones). This is used only for matching
  operations in case of spatial input. The oe\_\* functions will select
  the geographical area closest to the input place with the highest
  "level". See [geofabrik_zones](geofabrik_zones.md) for an example of a
  (proper) hierarchical structure.

- geometry:

  The `sfg` for that geographical region, rectangular. See also
  [`oe_get_boundary()`](oe_get_boundary.md) to extract the proper
  geographical boundaries.

## Source

<https://download.bbbike.org/osm/>

## Details

An `sf` object containing the URLs, names, and file_size of the OSM
extracts stored at <https://download.bbbike.org/osm/bbbike/>.

## See also

Other provider's-database: [`geofabrik_zones`](geofabrik_zones.md),
[`openstreetmap_fr_zones`](openstreetmap_fr_zones.md)
