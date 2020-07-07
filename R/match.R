#' Match input place with a geographical zone
#'
#' This function is used to match the input `place` with the url of the
#' corresponding pbf file (and its file size, if present).
#'
#' @inheritParams osmext_get
#' @param ... arguments passed to other methods
#'
#' @return A list with two elements, named `url` and `file_size`. The first
#'   element is the url of the file associated with the input `place`, while
#'   the second element is the size of the file.
#' @export
#'
#' @details ABC
#'
#' @examples
#' osmext_match("Italy")
osmext_match = function(place, ...) {
  UseMethod("osmext_match")
}

#' @rdname osmext_match
#' @export
osmext_match.default <- function(place, ...) {
  stop(
    "At the moment there is no support for matching objects of class ",
    class(place)[1], ".",
    " Feel free to open a new issue at ... .", call. = FALSE
  )
}

#' @inheritParams osmext_get
#' @rdname osmext_match
#' @export
osmext_match.sfc_POINT <- function(
  place,
  provider = "geofabrik",
  verbose = FALSE,
  ...
) {
  # For the moment we support only length-one sfc_POINT objects
  if (length(place) > 1L) {
    stop(
      "At the moment we support only length-one sfc_POINT objects for 'place' parameter.",
      " Feel free to open a new issue at ...",
      call. = FALSE
    )
  }

  # Load the data associated with the chosen provider.
  provider_data <- load_provider_data(provider)

  # Check the CRS
  if (sf::st_crs(place) != sf::st_crs(provider_data)) {
    place = sf::st_transform(place, crs = sf::st_crs(provider_data))
  }

  # Spatial subset according to sf::st_intersects (maybe add a parameter for that)
  matched_zones = provider_data[place, ]

  # Check that the input zone intersects at least 1 area
  if (nrow(matched_zones) == 0L) {
    stop("The input place does not intersect any area for the chosen provider.")
  }

  # What to do if there are multiple matches?  (maybe add a parameter for that)
  if (nrow(matched_zones) > 1L) {
    # Check for the "smallest" zone
    smallest_zone = matched_zones[which.max(matched_zones[["level"]]), ]
  }

  # Return a list with the url and the file_size of the matched place
  result <- list(
    url = smallest_zone[["pbf"]],
    file_size = smallest_zone[["pbf_file_size"]]
  )
  result

}

#' @inheritParams osmext_get
#' @rdname osmext_match
#' @export
osmext_match.numeric = function(
  place,
  provider = "geofabrik",
  verbose = FALSE,
  ...
) {
  # In this case I just need to build the appropriate object and create a
  # wrapper around osmext_match.sfc_POINT
  if (length(place) != 2L) {
    stop(
      "You need to provide a pair of coordinates and you passed as input",
      " a vector of length ", length(place)
    )
  }

  # Build the sfc_POINT object
  place <- sf::st_sfc(sf::st_point(place), crs = 4326)

  osmext_match(place, provider = provider, verbose = verbose, ...)
}

#' @inheritParams osmext_get
#' @rdname osmext_match
#' @export
osmext_match.character <- function(
  place,
  provider = "geofabrik",
  match_by = "name",
  max_string_dist = 1,
  interactive_ask = FALSE,
  verbose = FALSE,
  ...
  ) {
  # For the moment we support only length-one character vectors
  if (length(place) > 1L) {
    stop(
      "At the moment we support only length-one character vectors for 'place' parameter.",
      " Feel free to open a new issue at ...",
      call. = FALSE
    )
  }

  # Load the data associated with the chosen provider.
  provider_data <- load_provider_data(provider)

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
  matching_dists <- utils::adist(provider_data[[match_by]], place, ignore.case = TRUE)
  best_match_id <- which.min(matching_dists)
  # WHAT TO DO IF THERE ARE MULTIPLE BEST MATCHES?
  best_matched_place <- provider_data[best_match_id, ]

  # Check if the best match is still too far
  high_distance <- matching_dists[best_match_id, 1] > max_string_dist

  if (high_distance) {
    if (verbose) {
      message(
        "No exact matching found for place = ", place, ". ",
        "Best match is ", best_matched_place[[match_by]], "."
      )
    }
    if (interactive() && interactive_ask) {
      continue <- utils::menu(
        choices = c("Yes", "No"),
        title = "Would you like to download this file?"
      )
      # since the options are Yes/No, then Yes == 1L
      if (continue != 1L) {
        stop("Search for a closer match in the chosen provider's database.",
             call. = FALSE
        )
      }
    } else {
      stop(
        "String distance between best match and the input place is ",
        matching_dists[best_match_id, 1],
        ", while the maximum threshold distance is equal to ",
        max_string_dist,
        ". You should increase the max_string_dist parameter, ",
        "look for a closer match in the chosen provider database",
        " or consider using a different match_by variable.", call. = FALSE
      )
    }
  }

  # Return a list with the url and the file_size of the matched place
  result <- list(
    url = best_matched_place[["pbf"]],
    file_size = best_matched_place[["pbf_file_size"]]
  )
  result
}

# The following function is used just to load the correct provider database
load_provider_data <- function(provider) {
  if (provider %!in% osmext_available_providers()) {
    stop(
      "You can only select one of the following providers: ",
      osmext_available_providers(),
      call. = FALSE
    )
  }

  provider_data <- switch(
    provider,
    "geofabrik" = geofabrik_zones
  )
  provider_data
}

#' Check for patterns in the provider's data columns
#'
#' This function is used to explore the provider's data and check for patterns
#' in the existing columns
#'
#' @inheritParams osmext_get
#' @param pattern Character string for the pattern that should be matched
#'
#' @return A
#' @export
#'
#' @examples
#' osmext_check_pattern(
#' pattern = "Yorkshire",
#' provider = "geofabrik",
#' match_by = "name"
#' )
osmext_check_pattern <- function(
  pattern,
  provider = "geofabrik",
  match_by = "name"
) {
  # Check that the input pattern is a character vector
  if (!is.character(pattern)) {
    pattern <- structure( # taken from base::grep
      as.character(pattern),
      names = names(pattern)
    )
  }
  # Load the dataset associated with the chosen provider
  provider_data <- load_provider_data(provider)

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
  match_by_column <- provider_data[[match_by]]


  # Then we extract and return only the elements of the match_by_column that
  # match the input pattern.
  result <- grep(pattern, match_by_column, value = TRUE)
  result

}

grep
