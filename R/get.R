#' Title
#'
#' @param place Description of the geographical area that should be download
#'   through the chosen `provider`. Can be either a length-1 character vector, a
#'   length-1 `sfc_POINT` object or a numeric vector with length 2. See details
#'   and examples.
#' @param provider Which provider should be used to download the data? For the
#'   moment we support only [`"geofabrik"`](http://download.geofabrik.de/).
#' @param match_by Which column of the provider data should be used for matching
#'   the input place with the provider's data? The default is "name". Check
#'   details and examples to understand how this parameter works. Ignored if
#'   `place` is not a character vector since the matching is performed through a
#'   spatial operation.
#' @param max_string_dist Numeric value greater or equal than 0. What is the
#'   maximum distance in fuzzy matching to tolerate before asking the user to
#'   select which zone to download? This parameter is set equal to 0 if
#'   `match_by` is equal to `iso3166_1_alpha2` or `iso3166_2`. Check details and
#'   examples to understand why this parameter is important. Ignored if `place`
#'   is not a character vector since the matching is performed through a spatial
#'   operation.
#' @param interactive_ask Boolean. If `TRUE` the function creates and
#'   interactive menu in case the best match is further than `max_string_dist`.
#'   Check details and examples to understand why this parameter is important.
#'   Ignored if `place` is not a character vector since the matching is
#'   performed through a spatial operation.
#' @param download_directory TODO
#' @param force_download TODO
#' @param max_file_size TODO
#' @param verbose Boolean. If `TRUE` the function prints informative messages.
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
  max_string_dist = 1,
  interactive_ask = FALSE,
  download_directory = osmext_download_directory(),
  force_download = FALSE,
  max_file_size = 5e+8,
  verbose = FALSE
) {
  1
}

