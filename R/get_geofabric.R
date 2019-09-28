#' Download osm data from geofabric
#'
#' @param name Name of the geofabric zone to download
#' @param format Format of data to download (currently only pbf supported)
#' @param layer Character string telling `sf` which OSM layer to import.
#' One of `points`, `lines` (the default), `multilinestrings`, `multipolygons` or `other_relations`
#' @param download_directory Where to download the data? `tempdir()` by default.
#'
#' @export
#' @examples
#' get_geofabric("isle of man")
#' \donttest{
#' get_geofabric("andorra")
#' get_geofabric("west-yorkshire")
#' }
get_geofabric = function(
  name = "west-yorkshire",
  format = "pbf",
  layer = "lines",
  download_directory = tempdir()
  # unzip_directory = tempdir()
  ) {

  geofabric_matches = geofabric_zones[geofabric_zones$name == name, ]

  # browser()

  if(nrow(geofabric_matches) == 0) {
    matching_dist = as.numeric(utils::adist(geofabric_zones$name, name))
    best_match = which.min(matching_dist)
    geofabric_matches = geofabric_zones[best_match, ]
    message("No exact matching geofabric zone. Best match is ", geofabric_matches$name)
    # add would you like to proceed message?
  }

  zone_url = geofabric_matches$pbf_url

  # download_path = file.path(download_directory, paste0(zone, ".zip"))
  download_path = file.path(download_directory, paste0(name, ".osm.pbf"))
  if(!file.exists(download_path)) {
    message("Downloading ", zone_url, " to ", download_path)
    utils::download.file(url = zone_url, destfile = download_path)
  } else {
    message("Data already detected in ", download_path)
  }

  # @param unzip_directory Where to unzip the data? `tempdir()` by default. # todo: add when ready
  # unzip(zipfile = download_path, exdir = unzip_directory)
  # message("The following shapefiles have been downloaded:")
  # shapefiles = list.files(path = unzip_directory, pattern = ".shp", full.names = TRUE)
  # return(shapefiles)
  sf::read_sf(download_path, layer = layer) # todo: use alternative read command that uses custom .ini file
}

# old version of function -------------------------------------------------
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

