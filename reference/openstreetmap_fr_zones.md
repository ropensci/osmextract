# An sf object of geographical zones taken from download.openstreetmap.fr

An `sf` object containing the URLs, names, and file-sizes of the OSM
extracts stored at <http://download.openstreetmap.fr/>.

## Usage

``` r
openstreetmap_fr_zones
```

## Format

An `sf` object with 1190 rows and 7 columns:

- id:

  A unique ID for each area. It is used by
  [`oe_update()`](oe_update.md).

- name:

  The, usually English, long-form name of the city.

- parent:

  The identifier of the next larger excerpts that contains this one, if
  present.

- level:

  An integer code between 1 and 4. Check
  <http://download.openstreetmap.fr/polygons/> to understand the
  hierarchical structure of the zones. 1L correspond to the biggest
  areas. This is used only for matching operations in case of spatial
  input.

- pbf:

  Link to the latest `.osm.pbf` file for this region.

- pbf_file_size:

  Size of the pbf file in bytes.

- geometry:

  The `sfg` for that geographical region, rectangular. See also
  [`oe_get_boundary()`](oe_get_boundary.md) to extract the proper
  geographical boundaries.

## Source

<http://download.openstreetmap.fr/>

## See also

Other provider's-database: [`bbbike_zones`](bbbike_zones.md),
[`geofabrik_zones`](geofabrik_zones.md)
