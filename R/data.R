#' An sf object of geographical zones taken from geofabrik.de
#'
#' An `sf` object containing the URLs, names and file-sizes of the OSM
#' extracts stored at <https://download.geofabrik.de/>. You can read more
#' details about these data at the following link:
#' <https://download.geofabrik.de/technical.html>.
#'
#' @format An sf object with `r nrow(geofabrik_zones)` rows and
#' `r ncol(geofabrik_zones)` columns:
#' \describe{
#'   \item{id}{A unique identifier. It contains letters, numbers and potentially
#'   the characters "-" and "/".}
#'   \item{name}{The, usually English, long-form name of the area.}
#'   \item{parent}{The identifier of the next larger excerpts that contains this
#'   one, if present.}
#'   \item{level}{An integer code between 1 and 4. If level = 1, then the zone
#'   corresponds to one of the continents (Africa, Antarctica, Asia, Australia
#'   and Oceania, Central America, Europe, North America, and South America) or
#'   the Russian Federation. If level = 2, then the zone corresponds to the
#'   continent's subregions (i.e. the countries such as Italy, Great Britain,
#'   Spain, USA, Mexico, Belize, Morocco, Peru and so on). There are also some
#'   exceptions that correspond to the Special Sub Regions (according to the
#'   Geofabrik definition), which are: South Africa (includes Lesotho), Alps,
#'   Britain and Ireland, Germany + Austria + Switzerland, US Midwest, US
#'   Northeast, US Pacific, US South, US West, and all US states. Level = 3L
#'   corresponds to the subregions of each state (or each level 2 zone). For
#'   example, the West Yorkshire, which is a subregion of England, is a level 3
#'   zone. Finally, level = 4 correspond to the subregions of the third level
#'   and it is mainly related to some small areas in Germany. This field is used
#'   only for matching operations in case of spatial input.}
#'   \item{iso3166-1_alpha2}{A character vector of two-letter [ISO3166-1
#'   codes](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2). This will be set
#'   on the smallest extract that still fully (or mostly) contains the entity
#'   with that code; e.g. the code "DE" will be given for the Germany extract
#'   and not for Europe even though Europe contains Germany. If an extract
#'   covers several countries and no per-country extracts are available (e.g.
#'   Israel and Palestine), then several ISO codes will be given (such as "PS
#'   IL" for "Palestine and Israel").}
#'   \item{iso3166_2}{A character vector of usually five-character [ISO3166-2
#'   codes](https://en.wikipedia.org/wiki/ISO_3166-2). The same rules as above
#'   apply. Some entities have both an *iso3166-1* and *iso3166-2* code. For
#'   example, the *iso3166_2* code of each US State is "US - " plus the code of
#'   the state.}
#'   \item{pbf}{Link to the latest `.osm.pbf` file for this region.}
#'   \item{pbf_file_size}{Size of the `.pbf` file in bytes.}
#'   \item{geometry}{The `sfg` for that geographical region. These are not the
#'   country boundaries, but a buffer around countries. Check
#'   `oe_get_boundary()` to extract the geographical boundaries.}
#' }
#'
#' @family provider's-database
#' @source <https://download.geofabrik.de/>
"geofabrik_zones"

#' An sf object of geographical zones taken from bbbike.org
#'
#' Start bicycle routing for... everywhere!
#'
#' An `sf` object containing the URLs, names, and file_size of the OSM extracts
#' stored at <https://download.bbbike.org/osm/bbbike/>.
#'
#' @format An `sf` object with `r nrow(bbbike_zones)` rows and
#' `r ncol(bbbike_zones)` columns:
#' \describe{
#'   \item{name}{The, usually English, long-form name of the city.}
#'   \item{pbf}{Link to the latest `.osm.pbf` file for this region.}
#'   \item{pbf_file_size}{Size of the pbf file in bytes.}
#'   \item{id}{A unique identifier. It contains letters, numbers and potentially
#'   the characters "-" and "/".}
#'   \item{level}{An integer code always equal to 3 (since the bbbike data
#'   represent non-hierarchical geographical zones). This is used only for
#'   matching operations in case of spatial input. The oe_* functions will
#'   select the geographical area closest to the input place with the highest
#'   "level". See [geofabrik_zones] for an example of a (proper) hierarchical
#'   structure.}
#'   \item{geometry}{The `sfg` for that geographical region, rectangular. See
#'   also `oe_get_boundary()` to extract the proper geographical boundaries.}
#' }
#'
#' @family provider's-database
#' @source \url{https://download.bbbike.org/osm/}
"bbbike_zones"

#' An sf object of geographical zones taken from download.openstreetmap.fr
#'
#' An `sf` object containing the URLs, names, and file-sizes of the OSM
#' extracts stored at <http://download.openstreetmap.fr/>.
#'
#' @format An `sf` object with `r nrow(openstreetmap_fr_zones)` rows and
#' `r ncol(openstreetmap_fr_zones)` columns:
#' \describe{
#'   \item{id}{A unique ID for each area. It is used by `oe_update()`.}
#'   \item{name}{The, usually English, long-form name of the city.}
#'   \item{parent}{The identifier of the next larger excerpts that contains
#'   this one, if present.}
#'   \item{level}{An integer code between 1 and 4. Check
#'   <http://download.openstreetmap.fr/polygons/> to understand the hierarchical
#'   structure of the zones. 1L correspond to the biggest areas. This is used
#'   only for matching operations in case of spatial input.}
#'   \item{pbf}{Link to the latest `.osm.pbf` file for this region.}
#'   \item{pbf_file_size}{Size of the pbf file in bytes.}
#'   \item{geometry}{The `sfg` for that geographical region, rectangular. See
#'   also `oe_get_boundary()` to extract the proper geographical boundaries.}
#' }
#'
#' @family provider's-database
#' @source \url{http://download.openstreetmap.fr/}
"openstreetmap_fr_zones"

#' An sf object of geographical zones taken from download.openstreetmap.fr
#'
#' This object represent a minimal provider's database and it should be used
#' only for examples and tests.
"test_zones"
