#' Returns a single sf feature associated with a search term
#'
#' Documentation: wip, not yet exported
oe_search = function(
  query = "Leeds",
  base_url = "https://nominatim.openstreetmap.org",
  destfile = tempfile(fileext = ".geojson")
  ) {
  u = paste0(base_url, "/search?q=", query, "&limit=1&format=geojson")
  download.file(url = u, destfile = destfile)
  sf::read_sf(destfile)
}
