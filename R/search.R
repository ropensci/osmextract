#' Search for a place and return an sf data frame locating it
#'
#' This (at the moment internal and experimental) function provides a simple
#' interface to the [nominatim](https://nominatim.openstreetmap.org) service for
#' finding the geographical location of place names.
#'
#' @return An `sf` object corresponding to the input place. The `sf` object is
#'   read by `sf::st_read()` and it is based on a `geojson` file returned by
#'   Nominatim API.
#'
#' @param place Text string containing the name of a place the location of
#'   which is to be found, such as `"Leeds"` or `"Milan"`.
#' @param base_url The URL of the nominatim server to use. The main
#'   open server hosted by OpenStreetMap is the default.
#' @param destfile The name of the destination file where the output
#'   of the search query, a `.geojson` file, should be saved.
#' @param ... Extra arguments that are passed to `sf::st_read`.
oe_search = function(
  place,
  base_url = "https://nominatim.openstreetmap.org",
  destfile = tempfile(fileext = ".geojson"),
  ...
  ) {
  # See https://nominatim.org/release-docs/develop/api/Overview/ for more
  # details realted to the URL
  check_nominatim_status()

  # Actually run the query
  result = httr::RETRY(
    verb = "GET",
    url = base_url,
    path = "search", # endpoint = search
    # the following is like ?q = place&limit=1&format=geojson
    query = list(q = place, limit = 1, format = "geojson"),
    httr::write_disk(destfile, overwrite = TRUE),
    httr::timeout(300L)
  )
  httr::stop_for_status(result, "look up location with Nominatim API")

  sf::st_read(destfile, quiet = TRUE, ...)
}

check_nominatim_status = function() {
  status = httr::RETRY(
    verb = "GET",
    url = "https://nominatim.openstreetmap.org/",
    path = "status.php", #path is endpoint
    query = list(format = "json"), # this is like ?format=json
    httr::timeout(300L),
    quiet = TRUE
  )
  if (httr::http_type(status) != "application/json") {
    stop("Nominatim API did not return json when testing status", call. = FALSE)
  }

  httr::stop_for_status(status, "check Nominatim API status")

  # From https://nominatim.org/release-docs/develop/api/Status/: On error will
  # also return HTTP status code 200 and a structure with error code and
  # message, e.g.
  # {
  #   "status": 700
  #   "message": "Database connection failed"
  # }
  # So, I need to check that status
  status_JSON = jsonlite::fromJSON(
    txt = httr::content(status, as = "text"),
    simplifyVector = FALSE
  )

  if (status_JSON[["status"]] != 0) {
    stop("Error connecting to Nominatim tool", call. = FALSE)
  }

  status_JSON
}
