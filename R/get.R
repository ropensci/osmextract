#' Title
#'
#' @param place String for the geographic zone that should be downloaded and
#'   loaded.
#' @param provider Which provider should be used to download the data associated
#'   to the mathced `place`? For the moment we support only
#'   [`"geofabrik"`](http://download.geofabrik.de/).
#' @param match_by Which column of the provider data should be used for matching
#'   the input place? The default value is "name". Check details and examples to
#'   understand why this parameter is important.
#' @param format File format that will be downloaded from the chosen provider.
#'   For the moment only the .osm.pbf format for download
#' @param max_string_dist What is the maximum distance in fuzzy matching to
#'   tolerate before asking the user to select which zone to download?
#' @param interactive_ask What to do is the closest match is further than max_string_dist?
#' @param verbose Should the user be asked before downloading the file?
#' @param ... Additional arguments passed to [`sf::st_read()`]
#'
#' @return A
#' @export
#' @details ABC
#'
#' @examples
#' 1 + 1
osmext_get = function(
  place,
  provider = "geofabrik",
  match_by = "name",
  format = "pbf",
  max_string_dist = 1,
  interactive_ask = FALSE,
  verbose = TRUE,
  ...
) {
  # Match the input zone with the provider's data.
  matched_zone <- osmext_match(
    place = place,
    provider = provider,
    match_by = match_by,
    max_string_dist = max_string_dist,
    interactive_ask = interactive_ask,
    verbose = verbose
  )
  matched_zone
}

