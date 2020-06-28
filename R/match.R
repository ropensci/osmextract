#' Match input place with a url
#'
#' @param place A
#' @param ... B
#'
#' @return ABC
#' @export
#'
#' @examples
#' 1 + 1
osmext_match = function(place, ...) {
  UseMethod("osmext_match")
}

#' @rdname osmext_match
#' @export
osmext_match.default <- function(place, ...) {
  stop("At the moment there is no support for matching objects of class ",
       class(place)[1], ".",
       " Feel free to open a new issue at ... .", call. = FALSE)
}

#' @param provider C
#' @param match_by D
#' @param max_string_dist E
#' @param interactive_ask F
#' @param verbose G
#' @rdname osmext_match
#' @export
osmext_match.character <- function(
  place,
  ...,
  provider = "geofabrik",
  match_by = "name",
  max_string_dist = 1,
  interactive_ask = FALSE,
  verbose = TRUE
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
    pbf_url = best_matched_place[["pbf"]],
    pbf_file_size = best_matched_place[["pbf_file_size"]]
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


