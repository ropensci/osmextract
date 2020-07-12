#' A `data.frame` of geographical zones taken from Geofabrik
#'
#' A `sf` `data.frame` containing the URLs, names and file_size of the OSM extracts
#' stored at \url{https://download.geofabrik.de/}. You can read more details
#' about these data at the following link: \url{https://download.geofabrik.de/technical.html}.
#'
#'
#' @format A sf dataframe with 430 rows and 14 columns:
#' \describe{
#'   \item{id}{A unique identifier, contains letters, numbers and potentially
#'   the characters "-" and "/".}
#'   \item{name}{The, usually English, long-form name of the area.}
#'   \item{parent}{The identifier of the next larger excerpts that contains this
#'   one, if present.}
#'   \item{level}{An integer code between 1 and 3. If level == 1L then the
#'   zone corresponds to one of the continents plus the Russian Federation:
#'   Africa, Antartica, Asia, Australia and Oceania, Central America, Europe,
#'   North America, Russian Federation and South America. If level == 2L then
#'   the zone corresponds to the continent's subregions (i.e. the countries,
#'   such as Italy, Great Britain, Spain, USA, Mexico, Belize, Morocco, Peru and
#'   so on). There are also some exceptions that correspond to the Special Sub
#'   Regions (according to their geofabrik definition), which are: South Africa
#'   (includes Lesotho), Alps, Britain and Ireland, Germany + Austria +
#'   Switzerland, USMidwest, US Northeast, US Pacific, US South, US West and all
#'   US states. level == 3L correspond to the subregions of each state (or each
#'   level 2 zone). For example the West Yorkshire, which is a subregion of
#'   England, is a level 3 zone.}
#'   \item{iso3166-1:alpha2}{A character vector of two-letter ISO3166-1 codes.
#'   This will be set on the smallest extract that still fully (or mostly)
#'   contains the entity with that code; e.g. the code "DE" will be given for
#'   the Germany extract and not for Europe even though Europe contains Germany.
#'   If an extract covers several countries and no per-contry extracts are
#'   available (e.g. Israel and Palestine), then several ISO codes will be
#'   given (such as "PS - IL" for "Palestine and Israel").}
#'   \item{iso3166_2}{A character vector of usually five-character ISO3166-2
#'   codes. The same rules as above apply. Some entities have both an iso3166-1
#'   and and iso3166-2 code.}
#'   \item{pbf}{Link to the latest .osm.pbf file for this region.}
#'   \item{bz2}{Link to the latest .osm.bz2 file for this region.}
#'   \item{shp}{Link to the latest shape file for this region.}
#'   \item{pbf.internal}{Link to the latest .osm.pbf file with user data for
#'   this region (requires OSM login).}
#'   \item{history}{Link to the latest history file for this region (requires
#'   OSM login).}
#'   \item{taginfo}{Link to the Geofabrik taginfo instance for this region.}
#'   \item{updates}{Link to the updates directory (append /state.txt for status
#'   file).}
#'   \item{geometry}{The sfc for that geographical region. These are not the
#'   country boundaries but a buffer around countries.}
#'   \item{pbf_size_size}{Size of the pbf file in bytes.}
#' }
#'
#' @source \url{https://download.geofabrik.de/}
#' @aliases test_zones
"geofabrik_zones"

#' A `data.frame` of geographical zones taken from bbbike.org
#'
#' Start bicycle routing for... everywhere!
#'
#' A `sf` `data.frame` containing the URLs, names and file_size of the OSM extracts.
#' See \url{https://download.bbbike.org/osm/}.
#'
#' @format A sf dataframe with 430 rows and 14 columns:
#' \describe{
#'   \item{name}{The, usually English, long-form name of the city}
#'   \item{last_modified}{When was it last modified?}
#'   \item{type}{empty}
#'   \item{size}{Should be the size}
#'   \item{base_url}{The base URL for the city}
#'   \item{poly_url}{The .poly file location}
#'   \item{pbf}{Link to the latest .osm.pbf file for this region.}
#'   \item{geometry}{The sfc for that geographical region, rectangular.}
#' }
#'
#' @source \url{https://download.bbbike.org/osm/}
"bbbike_zones"

