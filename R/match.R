#' Match input place with a URL
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
#' @details The fields `iso3166_1_alpha2` and `iso3166_2` are used by geofabrik
#'   provider to perform matching operations using [ISO 3166-1
#'   alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) and [ISO
#'   3166-2](https://en.wikipedia.org/wiki/ISO_3166-2). See [geofabrik_zones]
#'   for more details.
#'
#'   If the input place is specified as a spatial point (either `sfc_POINT` or
#'   numeric coordinates), then the function will return the geographical area
#'   with the highest "level" intersecting the point. See the help pages of the
#'   chosen provider database for understanding the meaning of the "level"
#'   field. If there are multiple areas at the same "level" intersecting the
#'   input place, then the function will return the area whose centroid is
#'   closer to the input place.
#'
#'   If the input place is specified as a character vector and there are
#'   multiple plausible matches between the input place and the `match_by`
#'   column, then the function will return a warning and it will select the
#'   first match. See Examples.
#' @examples
#' # The simplest example:
#' oe_match("Italy")
#'
#' # The default provider is "geofabrik", but we can change that:
#' oe_match("Leeds", provider = "bbbike")
#'
#' # By default the matching operations are performed through the column "name"
#' # in the provider's database but this can be a problem:
#' \dontrun{
#' oe_match("Russia", quiet = FALSE)}
#' # so you can perform the matching operations using other columns in the
#' # provider's database:
#' oe_match("RU", match_by = "iso3166_1_alpha2")
#' # Run oe_providers() for a description of all providers and check the help
#' # pages of the corresponding databases to learn which fields are present.
#'
#' # You can always increase the max_string_dist argument to help the function:
#' \dontrun{
#' oe_match("Isle Wight", quiet = FALSE)}
#' oe_match("Isle Wight", max_string_dist = 3, quiet = FALSE)
#' # but be aware that it can be dangerous:
#' oe_match("London", max_string_dist = 3, quiet = FALSE)
#'
#' # Match the input zone using an sfc_POINT object:
#' milan_duomo = sf::st_sfc(sf::st_point(c(1514924, 5034552)), crs = 3003)
#' oe_match(milan_duomo, quiet = FALSE)
#' leeds = sf::st_sfc(sf::st_point(c(430147.8, 433551.5)), crs = 27700)
#' oe_match(leeds, provider = "bbbike")
#'
#' # Match the input zone using a numeric vector of coordinates
#' # (in which case crs = 4326 is assumed)
#' oe_match(c(9.1916, 45.4650)) # Milan, Duomo using CRS = 4326
#'
#' # It returns a warning since Berin is matched both with Benin and Berlin
#' oe_match("Berin", quiet = FALSE)
oe_match = function(place, ...) {
  UseMethod("oe_match")
}

#' @name oe_match
#' @export
oe_match.default = function(place, ...) {
  stop(
    "At the moment there is no support for matching objects of class ",
    class(place)[1], ".",
    " Feel free to open a new issue at github.com/itsleeds/osmextract",
    call. = FALSE
  )
}

#' @inheritParams oe_get
#' @name oe_match
#' @export
oe_match.sfc_POINT = function(
  place,
  provider = "geofabrik",
  quiet = FALSE,
  ...
) {
  # For the moment we support only length-one sfc_POINT objects
  if (length(place) > 1L) {
    stop(
      "At the moment we support only length-one sfc_POINT objects for 'place'",
      " parameter. Feel free to open a new issue at ",
      "https://github.com/ITSLeeds/osmextract",
      call. = FALSE
    )
  }

  # Load the data associated with the chosen provider.
  provider_data = load_provider_data(provider)

  # Check the CRS
  if (sf::st_crs(place) != sf::st_crs(provider_data)) {
    place = sf::st_transform(place, crs = sf::st_crs(provider_data))
  }

  # Spatial subset according to sf::st_intersects (maybe add a parameter for
  # that)
  matched_zones = provider_data[place, op = sf::st_intersects]

  # Check that the input zone intersects at least 1 area
  if (nrow(matched_zones) == 0L) {
    stop("The input place does not intersect any area for the chosen provider.")
  }

  # If there are multiple matches, we will select the geographical zones with
  # the highest level (more or less they correspond to the smallest areas)
  if (nrow(matched_zones) > 1L) {
    if (isFALSE(quiet)) {
      message(
        "The input place was matched with multiple geographical areas. ",
        "Selecting the areas with the highest \"level\". See the help page",
        " associated to the chosen provider for an explanation of the ",
        "meaning of the \"level\" field"
      )
    }


    # Select the zones with the highest level. I do not use which.max since I
    # want to select all occurrences, not only the first one
    matched_zones = matched_zones[
      matched_zones[["level"]] == max(matched_zones[["level"]], na.rm = TRUE),
    ]
  }

  # If, again, there are multiple matches with the same "level", we will select
  # only the area closest to the input place.
  if (nrow(matched_zones) > 1L) {
    if (isFALSE(quiet)) {
      message(
        "The input place was matched with multiple geographical areas with",
        " the same \"level\". Selecting the area whose centroid is closer ",
        "to the input place"
      )
    }

    nearest_id_centroid = sf::st_nearest_feature(
      place,
      sf::st_centroid(sf::st_geometry(matched_zones))
    )
    matched_zones = matched_zones[nearest_id_centroid,]
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
      "https://github.com/ITSLeeds/osmextract",
      call. = FALSE
    )
  }

  # See https://github.com/ITSLeeds/osmextract/pull/125
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
    warning(
      "The input place was matched with multiple geographical zones: ",
      paste(provider_data[[match_by]][best_match_id], collapse = " - "),
      ". Selecting the first match.",
      call. = FALSE,
      immediate. = TRUE
    )
    best_match_id = best_match_id[1L]
  }
  best_matched_place = provider_data[best_match_id, ]

  # Check if the best match is still too far
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
    # the matched value from that other provider:
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
          ". Returning that. "
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

    # 3. Otherwise, we can use oe_search to look for the lat/long coordinates of the input place
    if (isFALSE(quiet)) {
      message(
        "No exact match found in any OSM provider data.",
        " Searching for the location online."
      )
    }

    place_online = oe_search(place = place)
    # I added Sys.sleep(1) since the usage policty of OSM nominatim (see
    # https://operations.osmfoundation.org/policies/nominatim/) requires max 1
    # request per second.
    Sys.sleep(1)
    return(
      oe_match(
        place = sf::st_geometry(place_online),
        provider = provider,
        quiet = quiet
      )
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
#' @param provider Which provider should be used? Check a summary of all
#'   available providers with [`oe_providers()`].
#' @param match_by Column name of the provider's database that will be used to
#'   find the match.
#' @param full_row Boolean. Return all columns for the matching rows? `FALSE` by
#'   default.
#'
#' @return A character vector or a subset of the provider's database.
#' @export
#'
#' @examples
#' \dontrun{
#' oe_match("Yorkshire", quiet = FALSE)}
#' oe_match_pattern("Yorkshire")
#'
#' res = oe_match_pattern("Yorkshire", full_row = TRUE)
#' sf::st_drop_geometry(res)[1:3]
oe_match_pattern = function(
  pattern,
  provider = "geofabrik",
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
  # Load the dataset associated with the chosen provider
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

  # Extract the appropriate vector
  match_by_column = provider_data[[match_by]]

  # Then we extract only the elements of the match_by_column that match the
  # input pattern.
  match_ID = grep(pattern, match_by_column, ignore.case = TRUE)

  # If full_row is TRUE than return the corresponding row of provider_data,
  # otherwise just the matched pattern.
  if (isTRUE(full_row)) {
    provider_data[match_ID, ]
  } else {
    match_by_column[match_ID]
  }
}

