#' Download osm data from geofabric
#'
#' @inheritParams read_pbf
#' @param name Name of the geofabric zone to download
#' @param layer Character string telling `sf` which OSM layer to import.
#' One of `points`, `lines` (the default), `multilinestrings`, `multipolygons` or `other_relations`
#' @param download_directory Where to download the data? `tempdir()` by default.
#' If you want to download your data into a persistend directory, set
#' `GF_DOWNLOAD_DIRECTORY=/path/for/osm/data` in your `.Renviron` file, e.g. with
#' `usethis::edit_r_environ()`.
#' @param ask Should the user be asked before downloading the file?
#' @param max_dist What is the maximum distance in fuzzy matching to tolerate before asking
#' the user to select which zone to download?
#'
#' @export
#' @examples
#' get_geofabric("isle of man")
#' \donttest{
#' get_geofabric(name = "andorra") # try other names, e.g. name = "west-yorkshire"
#' # user asked to choose closest match when interactive
#' get_geofabric("kdljfdl", ask = FALSE)
#' # get zone associated with a point
#' name = sf::st_sfc(sf::st_point(c(0, 53)), crs = 4326)
#' get_geofabric(name)
#' }
get_geofabric = function(
  name = "west-yorkshire",
  # format = "pbf",
  layer = "lines",
  attributes = make_additional_attributes(layer = layer),
  download_directory = gf_download_directory(),
  ask = TRUE,
  max_dist = 3
  ) {

  if(inherits(name, "sf") | inherits(name, "sfc")) {
    geofabric_matches = gf_find_sf(name, ask)
  } else {
    geofabric_matches = gf_find(name, ask, max_dist)
  }
  if(is.null(geofabric_matches)) {
    # Match failed with message from gf_find
    return(NULL)
  }

  large_size = grepl(pattern = "G", x = geofabric_matches$size_pbf)
  if(interactive() & ask & large_size) {
    message("This is a large file ", geofabric_matches$size_pbf)
    continue = utils::menu(choices = c("Yes", "No"), title = "Would you like to download this file?")
    if(continue != 1L) {# for the same reasoning as before
      message("Aborted by user.")
      return(NULL)
    }
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

gf_download_directory = function(){
  d = Sys.getenv("GF_DOWNLOAD_DIRECTORY")
  if(nchar(d) == 0) {
    d = tempdir()
  }
  d
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

