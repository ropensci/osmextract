#' Download OSM data from [osmextractr.de](http://www.osmextractr.de/)
#'
#' @inheritParams read_pbf
#' @param name String or [`sf::sf`] spatial object of the osmextractr zone
#' to download. See examples.
#' @param layer Character string telling `sf` which OSM layer to import.
#' One of `points`, `lines` (the default), `multilinestrings`, `multipolygons` or `other_relations`
#' @param download_directory Where to download the data? `tempdir()` by default.
#' If you want to download your data into a persistent directory, set
#' `GF_DOWNLOAD_DIRECTORY=/path/for/osm/data` in your `.Renviron` file, e.g. with
#' `usethis::edit_r_environ()`.
#' @param ask Should the user be asked before downloading the file?
#' @param max_dist What is the maximum distance in fuzzy matching to tolerate before asking
#' the user to select which zone to download?
#' @param op The binary spatial predicate used to identify the smallest osmextractr zones
#' that matches the simple feature input in `name`
#' @param ... Additional arguments passed to [`read_pbf()`]
#'
#' @export
#' @examples
#' \donttest{
#' get_osmextractr("isle of man")
#' andorra = get_osmextractr(name = "andorra") # try other names, e.g. name = "west-yorkshire"
#' head(andorra)
#' cycleways_andorra = get_osmextractr("andorra", key = "highway", value = "cycleway")
#' plot(cycleways_andorra)
#' # user asked to choose closest match when interactive
#' # get_osmextractr("kdljfdl", ask = FALSE) # not run to save time
#' # get zone associated with a point
#' name = sf::st_sfc(sf::st_point(c(-1.3, 50.7)), crs = 4326)
#' get_osmextractr(name)
#' name = sf::st_sfc(sf::st_point(c(0, 53)), sf::st_point(c(-2, 55)), crs = 4326)
#' gf_find_sf(name)
#' }
get_osmextractr = function(
  name = "west-yorkshire",
  # format = "pbf",
  layer = "lines",
  ...,
  attributes = make_additional_attributes(layer = layer),
  download_directory = gf_download_directory(),
  ask = TRUE,
  max_dist = 5,
  op = sf::st_contains
  ) {

  if(inherits(name, "sf") | inherits(name, "sfc")) {
    name = sf::st_geometry(name)
    if(length(name) > 1) {
      warning("Matching only based on the first feature.", immediate. = TRUE)
      message("Try sf::st_union() to convert into a single multi feature.")
    }
    osmextractr_matches = gf_find_sf(name, ask, op)
  } else {
    if(length(name) > 1) {
      name = name[1]
      warning("Matching only the first name supplied: ", name, immediate. = TRUE)
    }
    osmextractr_matches = gf_find(name, ask, max_dist)
  }
  if(is.null(osmextractr_matches)) {
    # Match failed with message from gf_find
    return(NULL)
  }

  large_size = grepl(pattern = "G", x = osmextractr_matches$size_pbf)
  if(interactive() & ask & large_size) {
    message("This is a large file ", osmextractr_matches$size_pbf)
    continue = utils::menu(choices = c("Yes", "No"), title = "Would you like to download this file?")
    if(continue != 1L) {# for the same reasoning as before
      message("Aborted by user.")
      return(NULL)
    }
  }

  zone_url = osmextractr_matches$pbf_url

  # download_path = file.path(download_directory, paste0(zone, ".zip"))
  download_path = file.path(download_directory, paste0(osmextractr_matches$name, ".osm.pbf"))
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
  read_pbf(download_path, layer = layer, attributes = attributes, ...)
}

gf_download_directory = function(){
  d = Sys.getenv("GF_DOWNLOAD_DIRECTORY")
  if(nchar(d) == 0) {
    d = tempdir()
  }
  d
}


#' Get the filename of a file downloaded from osmextractr
#'
#' @param name The name of the geofrabic zone. Must be an element in `osmextractr::osmextractr_zones$name`.
#' @inheritParams get_osmextractr
#'
#' @return A character vector.
#' @export
#' @examples
#' f = gf_filename("Isle of Wight")
#' f
#' file.exists(f)
gf_filename = function(
  name = "West Yorkshire",
  # format = "pbf",
  download_directory = gf_download_directory()
) {
  stopifnot(name %in% osmextractr::osmextractr_zones$name)
  file.path(download_directory, paste0(name, ".osm.pbf"))
}

# old version of function -------------------------------------------------
# @param format Format of data to download (currently only pbf supported)
# get_osmextractr_contry_continent = function(
#                          continent = "europe",
#                          country = "great-britain",
#                          region = NULL,
#                          download_directory = tempdir(),
#                          unzip_directory = tempdir()) {
#   country_only = country_url = paste0(
#     "http://download.osmextractr.de/",
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

