#' Match input place with a url
#'
#' This function is used to match an input `place` with the URL of a `.osm.pbf`
#' file (and its file-size, if present). The URLs are stored in several
#' provider's databases. See [oe_providers()] and examples.
#'
#' @inheritParams oe_get
#' @param ... arguments passed to other methods
#'
#' @return A list with two elements, named `url` and `file_size`. The first
#'   element is the URL of the `.osm.pbf` file associated with the input
#'   `place`, while the second element is the size of the file in bytes (which
#'   may be `NULL` or `NA`)
#' @export
#'
#' @seealso [oe_providers()] and [oe_match_pattern()].
#'
#' @details
#'
#' If the input place is specified as a spatial object (either `sf` or `sfc`),
#' then the function will return a geographical area that completely contains
#' the object (or an error). The argument `level` (which must be specified as an
#' integer between 1 and 4, extreme values included) is used to select between
#' multiple geographically nested areas. We could roughly say that smaller
#' administrative units correspond to higher levels. Check the help page of the
#' chosen provider for more details on `level` field. By default, `level =
#' NULL`, which means that `oe_match()` will return the area corresponding to
#' the highest available level. If there is no geographical area at the desired
#' level, then the function will return an error. If there are multiple areas at
#' the same `level` intersecting the input place, then the function will return
#' the area whose centroid is closest to the input place.
#'
#' If the input place is specified as a character vector and there are multiple
#' plausible matches between the input place and the `match_by` column, then the
#' function will return a warning and it will select the first match. See
#' Examples. On the other hand, if the approximate string distance between the
#' input `place` and the best match in `match_by` column is greater than
#' `max_string_dist`, then the function will look for exact matches (i.e.
#' `max_string_dist = 0`) in the other supported providers. If it finds an exact
#' match, then it will return the corresponding URL. Otherwise, if `match_by` is
#' equal to `"name"`, then it will try to geolocate the input `place` using the
#' [Nominatim API](https://nominatim.org/release-docs/develop/api/Overview/),
#' and then it will perform a spatial matching operation (see Examples and
#' introductory vignette), while, if `match_by != "name"`, then it will return
#' an error.
#'
#' The fields `iso3166_1_alpha2` and `iso3166_2` are used by Geofabrik provider
#' to perform matching operations using [ISO 3166-1
#' alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) and [ISO
#' 3166-2](https://en.wikipedia.org/wiki/ISO_3166-2) codes. See
#' [geofabrik_zones] for more details.
#'
#' @examples
#' # The simplest example:
#' oe_match("Italy")
#'
#' # The default provider is "geofabrik", but we can change that:
#' oe_match("Leeds", provider = "bbbike")
#'
#' # By default, the matching operations are performed through the column
#' # "name" in the provider's database but this can be a problem. Hence,
#' # you can perform the matching operations using other columns:
#' oe_match("RU", match_by = "iso3166_1_alpha2")
#' # Run oe_providers() for reading a short description of all providers and
#' # check the help pages of the corresponding databases to learn which fields
#' # are present.
#'
#' # You can always increase the max_string_dist argument, but it can be
#' # dangerous:
#' oe_match("London", max_string_dist = 3, quiet = FALSE)
#'
#' # Match the input zone using an sfc object:
#' milan_duomo = sf::st_sfc(sf::st_point(c(1514924, 5034552)), crs = 3003)
#' oe_match(milan_duomo, quiet = FALSE)
#' leeds = sf::st_sfc(sf::st_point(c(430147.8, 433551.5)), crs = 27700)
#' oe_match(leeds, provider = "bbbike")
#'
#' # If you specify more than one sfg object, then oe_match will select the OSM
#' # extract that covers all areas
#' milan_leeds = sf::st_sfc(
#'   sf::st_point(c(9.190544, 45.46416)), # Milan
#'   sf::st_point(c(-1.543789, 53.7974)), # Leeds
#'   crs = 4326
#' )
#' oe_match(milan_leeds)
#'
#' # Match the input zone using a numeric vector of coordinates
#' # (in which case crs = 4326 is assumed)
#' oe_match(c(9.1916, 45.4650)) # Milan, Duomo using CRS = 4326
#'
#' # The following returns a warning since Berin is matched both
#' # with Benin and Berlin
#' oe_match("Berin", quiet = FALSE)
#'
#' # If the input place does not match any zone in the chosen provider, then the
#' # function will test the other providers:
#' oe_match("Leeds")
#'
#' # If the input place cannot be exactly matched with any zone in any provider,
#' # then the function will try to geolocate the input and then it will perform a
#' # spatial match:
#' oe_match("Milan")
#'
#' # The level parameter can be used to select smaller or bigger geographical
#' # areas during spatial matching
#' yak = c(-120.51084, 46.60156)
#' \dontrun{
#' oe_match(yak, level = 3) # error
#' oe_match(yak, level = 2) # by default, level is equal to the maximum value
#' oe_match(yak, level = 1)}

oe_match = function(place, ...) {
  UseMethod("oe_match")
}

#' @name oe_match
#' @export
oe_match.default = function(place, ...) {
  stop(
    "At the moment there is no support for matching objects of class ",
    class(place)[1], ".",
    " Feel free to open a new issue at github.com/ropensci/osmextract",
    call. = FALSE
  )
}

#' @inheritParams oe_get
#' @name oe_match
#' @export
oe_match.bbox = function(place, ...) {
  # We just need to convert the bbox to a sfc object
  oe_match(sf::st_as_sfc(place), ...)
}

#' @inheritParams oe_get
#' @name oe_match
#' @export
oe_match.sf = function(
  place,
  ...
) {
  oe_match(sf::st_geometry(place), ...)
}

#' @inheritParams oe_get
#' @name oe_match
#' @export
oe_match.sfc = function(
  place,
  provider = "geofabrik",
  level = NULL,
  quiet = FALSE,
  ...
) {
  # Load the data associated with the chosen provider.
  provider_data = load_provider_data(provider)

  # Check if place has no CRS (i.e. NA_crs_, see ?st_crs) and, in that case, set
  # 4326 + raise a warning message.
  # See https://github.com/ropensci/osmextract/issues/185#issuecomment-810353788
  # for a discussion.
  if (is.na(sf::st_crs(place))) {
    warning(
      "The input place has no CRS, setting crs = 4326.",
      call. = FALSE
    )
    place = sf::st_set_crs(place, 4326)
  }

  # Check the CRS
  if (sf::st_crs(place) != sf::st_crs(provider_data)) {
    place = sf::st_transform(place, crs = sf::st_crs(provider_data))
  }

  # If there is more than one sfg object in place I will combine them
  if (length(place) > 1L) {
    place = sf::st_combine(place)
  }

  # Spatial subset according to sf::st_contains
  # See https://github.com/ropensci/osmextract/pull/168
  suppressMessages({matched_zones = provider_data[place, op = sf::st_contains]})

  # Check that the input zone intersects at least 1 area
  if (nrow(matched_zones) == 0L) {
    stop("The input place does not intersect any area for the chosen provider.")
  }

  # If there are multiple matches, we will select the geographical area with
  # the chosen level (or highest level if default).
  if (nrow(matched_zones) > 1L) {
    # See https://github.com/ropensci/osmextract/issues/160
    # Check the level parameter and, if NULL, set level = highest level.
    if (is.null(level)) {
      # Add a check to test if all(is.na(matched_zones[["level"]])) ?
      level = max(matched_zones[["level"]], na.rm = TRUE)
    }

    # Select the desired area(s)
    matched_zones = matched_zones[matched_zones[["level"]] == level, ]

    if (nrow(matched_zones) == 0L) {
      stop("The input place does not intersect any area at the chosen level.")
    }
  }

  # If, again, there are multiple matches with the same "level", we will select
  # only the area closest to the input place.
  if (nrow(matched_zones) > 1L) {

    suppressMessages({suppressWarnings({
      nearest_id_centroid = sf::st_nearest_feature(
        place,
        sf::st_centroid(sf::st_geometry(matched_zones))
      )
    })})

    matched_zones = matched_zones[nearest_id_centroid, ]
  }

  if (isFALSE(quiet)) {
    message(
      "The input place was matched with ", matched_zones[["name"]], ". "
    )
  }

  # Return a list with the URL and the file_size of the matched place
  result = list(
    url = matched_zones[["pbf"]],
    file_size = matched_zones[["pbf_file_size"]]
  )
  result

}

#' @inheritParams oe_get
#' @name oe_match
#' @export
oe_match.numeric = function(
  place,
  provider = "geofabrik",
  quiet = FALSE,
  ...
) {
  # In this case I just need to build the appropriate object and create a
  # wrapper around oe_match.sfc_POINT
  if (length(place) != 2L) {
    stop(
      "You need to provide a pair of coordinates and you passed as input",
      " a vector of length ", length(place)
    )
  }

  # Build the sfc_POINT object
  place = sf::st_sfc(sf::st_point(place), crs = 4326)

  oe_match(place, provider = provider, quiet = quiet, ...)
}

#' @inheritParams oe_get
#' @name oe_match
#' @export
oe_match.character = function(
  place,
  provider = "geofabrik",
  quiet = FALSE,
  match_by = "name",
  max_string_dist = 1,
  ...
  ) {
  # For the moment we support only length-one character vectors
  if (length(place) > 1L) {
    stop(
      "At the moment we support only length-one character vectors for",
      " 'place' parameter. Feel free to open a new issue at ",
      "https://github.com/ropensci/osmextract",
      call. = FALSE
    )
  }

  # See https://github.com/ropensci/osmextract/pull/125
  if (place == "ITS Leeds") {
    provider = "test"
  }

  # Load the data associated with the chosen provider.
  provider_data = load_provider_data(provider)

  # Check that the value of match_by argument corresponds to one of the columns
  # in provider_data
  if (match_by %!in% colnames(provider_data)) {
    stop(
      "You cannot set match_by = ", match_by,
      " since it's not one of the columns of the provider dataframe",
      call. = FALSE
    )
  }

  # If the user is looking for a match using iso3166_1_alpha2 or iso3166_2 codes
  # then max_string_dist should be 0
  if (match_by %in% c("iso3166_1_alpha2", "iso3166_2") & max_string_dist > 0) {
    max_string_dist = 0
  }

  # Look for the best match between the input 'place' and the data column
  # selected with the match_by argument.
  matching_dists = utils::adist(
    provider_data[[match_by]],
    place,
    ignore.case = TRUE
  )
  best_match_id = which(matching_dists == min(matching_dists, na.rm = TRUE))

  if (length(best_match_id) > 1L) {
    best_match_id = best_match_id[1L]
  }
  best_matched_place = provider_data[best_match_id, ]

  # Check if the best match is still too far
  # NB: The following operations should use the > instead of >= otherwise I can
  # never set max_string_dist = 0
  high_distance = matching_dists[best_match_id, 1] > max_string_dist

  # If the approximate string distance between the best match is greater than
  # the max_string_dist threshold, then:
  if (isTRUE(high_distance)) {

    # 1. Raise a message
    if (isFALSE(quiet)) {
      message(
        "No exact match found for place = ", place, " and provider = ",
        provider, ". ", "Best match is ", best_matched_place[[match_by]], ".",
        " \nChecking the other providers."
      )
    }

    # 2. Check the other providers and, if there is an exact match, just return
    # the matched value from the other provider:
    other_providers = setdiff(oe_available_providers(), provider)
    exact_match = FALSE
    for (other_provider in other_providers) {
      if (match_by %!in% colnames(load_provider_data(other_provider))) {
        next
      }
      all_match_by = load_provider_data(other_provider)[[match_by]]

      if (any(tolower(place) == tolower(all_match_by))) {
        exact_match = TRUE
        break
      }
    }

    if (exact_match) {
      if (isFALSE(quiet)) {
        message(
          "An exact string match was found using provider = ", other_provider,
          "."
        )
      }

      return(
       oe_match(
         place = place,
         provider = other_provider,
         match_by = match_by,
         quiet = TRUE,
         max_string_dist = max_string_dist
        )
      )
    }

    # 3. Otherwise, if match_by == name (since I think it doesn't make sense to
    # use Nominatim with other fields), then we can use oe_search to look for
    # the lat/long coordinates of the input place
    if (match_by == "name") {
      if (isFALSE(quiet)) {
        message(
          "No exact match found in any OSM provider data.",
          " Searching for the location online."
        )
      }

      place_online = oe_search(place = place)
      return(
        oe_match(
          place = sf::st_geometry(place_online),
          provider = provider,
          quiet = quiet
        )
      )
    }

    # 4. Return an error
    stop(
      "No tolerable match was found. ",
      "You should try increasing the max_string_dist parameter, ",
      "look for a closer match in another provider ",
      "or consider using a different match_by variable.",
      call. = FALSE
    )
  }

  if (isFALSE(quiet)) {
    message(
      "The input place was matched with: ",
      best_matched_place[[match_by]]
    )
  }

  result = list(
    url = best_matched_place[["pbf"]],
    file_size = best_matched_place[["pbf_file_size"]]
  )
  result
}

#' Check patterns in the provider's databases
#'
#' This function is used to explore the provider's databases and look for
#' patterns. This function can be useful in combination with [`oe_match()`] and
#' [`oe_get()`] for an easy match. See Examples.
#'
#' @param pattern Character string representing the pattern that should be
#'   explored.
#' @param match_by Column name of the provider's database that will be used to
#'   find the match.
#' @param full_row Boolean. Return all columns for the matching rows? `FALSE` by
#'   default.
#'
#' @return A list of character vectors or `sf` objects (according to the value
#'   of the parameter `full_row`). If no OSM zone can be matched with the input
#'   string, then the function returns an empty list.
#' @export
#'
#' @examples
#' oe_match_pattern("Yorkshire")
#'
#' res = oe_match_pattern("Yorkshire", full_row = TRUE)
#' lapply(res, function(x) sf::st_drop_geometry(x)[, 1:3])
#'
#' oe_match_pattern("ABC")
#' oe_match_pattern("Yorkshire", match_by = "ABC")
oe_match_pattern = function(
  pattern,
  match_by = "name",
  full_row = FALSE
) {
  # Check that the input pattern is a character vector
  if (!is.character(pattern)) {
    pattern = structure( # taken from base::grep
      as.character(pattern),
      names = names(pattern)
    )
  }

  # NB: The argument provider was removed in version 0.3.0

  # Create an empty list that will contain the output
  matches = list()

  for (id in setdiff(oe_available_providers(), "test")) {
    # Load the dataset associated with the chosen provider
    provider_data = load_provider_data(id)

    # Check that the value of match_by argument corresponds to one of the columns
    # in provider_data
    if (match_by %!in% colnames(provider_data)) {
      next()
    }

    # Extract the appropriate vector
    match_by_column = provider_data[[match_by]]

    # Then we extract only the elements of the match_by_column that match the
    # input pattern.
    match_ID = grep(pattern, match_by_column, ignore.case = TRUE)

    # If full_row is TRUE than return the corresponding row of provider_data,
    # otherwise just the matched pattern.
    if (length(match_ID) > 0L) {
      match = if (isTRUE(full_row)) {
        provider_data[match_ID, ]
      } else {
        match_by_column[match_ID]
      }

      matches[[id]] = match
    }
  }

  # Return
  matches
}

