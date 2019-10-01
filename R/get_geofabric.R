#' Download osm data from geofabric
#'
#' @inheritParams read_pbf
#' @param name Name of the geofabric zone to download
#' @param layer Character string telling `sf` which OSM layer to import.
#' One of `points`, `lines` (the default), `multilinestrings`, `multipolygons` or `other_relations`
#' @param download_directory Where to download the data? `tempdir()` by default.
#' @param ask Should the user be asked before downloading the file?
#' @param max_dist What is the maximum distance in fuzzy matching to tolerate before asking
#' the user to select which zone to download?
#'
#' @export
#' @examples
#' get_geofabric("isle of man")
#' \donttest{
#' get_geofabric("andorra")
#' get_geofabric("west-yorkshire")
#' # user asked to choose closest match when interactive
#' get_geofabric("kdljfdl")
#' }
get_geofabric = function(
  name = "west-yorkshire",
  # format = "pbf",
  layer = "lines",
  attributes = make_additional_attributes(layer = layer),
  download_directory = tempdir(),
  ask = TRUE,
  max_dist = 3
  ) {

  geofabric_matches = geofabric_zones[geofabric_zones$name == name, ]

  # browser()

  if(nrow(geofabric_matches) == 0) {
    matching_dist = as.numeric(utils::adist(geofabric_zones$name, name))
    best_match = which.min(matching_dist)
    geofabric_matches = geofabric_zones[best_match, ]
    high_distance = matching_dist[best_match] > max_dist
    message("No exact matching geofabric zone. Best match is ", geofabric_matches$name, " ", geofabric_matches$size_pbf)
    if(interactive() & ask & high_distance) {
      continue = utils::menu(choices = c(TRUE, FALSE), title = "Would you like to download this file?")
      if(!continue) {
        stop("Search in geofabric_zones for a closer match.")
      }
    }
    large_size = grepl(pattern = "G", x = geofabric_matches$size_pbf)
    if(interactive() & ask & high_distance) {
      message("This is a large file ", geofabric_matches$size_pbf)
      continue = utils::menu(choices = c(TRUE, FALSE), title = "Would you like to download this file?")
      if(!continue) {
        stop("Aborted by user.")
      }
    }
    # add would you like to proceed message?
  }

  zone_url = geofabric_matches$pbf_url

  # download_path = file.path(download_directory, paste0(zone, ".zip"))
  download_path = file.path(download_directory, paste0(name, ".osm.pbf"))
  if(!file.exists(download_path)) {
    message("Downloading ", zone_url, " to \n", download_path)
    utils::download.file(url = zone_url, destfile = download_path, mode = "wb")
  } else {
    message("Data already detected in ", download_path)
  }

  # @param unzip_directory Where to unzip the data? `tempdir()` by default. # todo: add when ready
  # unzip(zipfile = download_path, exdir = unzip_directory)
  # message("The following shapefiles have been downloaded:")
  # shapefiles = list.files(path = unzip_directory, pattern = ".shp", full.names = TRUE)
  # return(shapefiles)
  read_pbf(download_path, layer = layer, attributes = attributes)
}

# old version of function -------------------------------------------------
# @param format Format of data to download (currently only pbf supported)
# get_geofabric_contry_continent = function(
#                          continent = "europe",
#                          country = "great-britain",
#                          region = NULL,
#                          download_directory = tempdir(),
#                          unzip_directory = tempdir()) {
#   country_only = country_url = paste0(
#     "http://download.geofabrik.de/",
#     continent,
#     "/",
#     country
#   )
#   if(!is.null(region)) {
#     country_url = paste0(country_url, "/", region)
#   }
#   country_url = paste0(country_url, "-latest-free.shp.zip")
#   message("Trying ", country_url)
#   res = httr::GET(country_url)
#   url_ok = identical(httr::status_code(res), 200L)
#   if(!url_ok) {
#     message("No country file to download. See ", country_only, " for available regions.")
#     return(country_only)
#   }
#   message("Downloading ", country_url)
#   download_path = file.path(download_directory, paste0(country, ".zip"))
#   utils::download.file(url = country_url, destfile = download_path)
#   utils::unzip(zipfile = download_path, exdir = unzip_directory)
#   message("The following shapefiles have been downloaded:")
#   shapefiles = list.files(path = unzip_directory, pattern = ".shp", full.names = TRUE)
#   return(shapefiles)
# }

