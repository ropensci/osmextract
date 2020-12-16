#' Search for a place and return an sf data frame locating it
#'
#' This function provides a simple interface to the
#' [nominatim](https://nominatim.openstreetmap.org)
#' service for finding the geographical location of place names.
#'
#' @param place Text string containing the name of a place the location of
#'   which is to be found, such as `"Leeds"` or `"Milan"`.
#' @param base_url The URL of the nominatim server to use. The main
#'   open server hosted by OpenStreetMap is the default.
#' @param destfile The name of the destination file where the output
#'   of the search query, a `.geojson` file, should be saved.
oe_search = function(
  place = "Leeds",
  base_url = "https://nominatim.openstreetmap.org",
  destfile = tempfile(fileext = ".geojson")
  ) {
  u = paste0(base_url, "/search?q=", place, "&limit=1&format=geojson")
  utils::download.file(url = u, destfile = destfile)
  sf::read_sf(destfile)
}
