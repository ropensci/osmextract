#' Find geofabrik zones
#'
#' @inheritParams get_geofabrik
#'
#' @return A data frame representing the matching items from the Geofabrik website
#' @export
#'
#' @examples
#' gf_find("Andorra")
gf_find = function(name, ask = FALSE, max_dist = 5) {

  matching_dist = as.numeric(utils::adist(geofabrik_zones$name, name))
  best_match = which.min(matching_dist)
  geofabrik_matches = geofabrik_zones[best_match, ]
  high_distance = matching_dist[best_match] > max_dist
  if(high_distance) {
    message("No exact matching geofabrik zone. Best match is ", geofabrik_matches$name, " ", geofabrik_matches$size_pbf)
    if(interactive() & ask) {
      continue = utils::menu(choices = c("Yes", "No"), title = "Would you like to download this file?")
      if(continue != 1L) {# since the options are Yes/No, then Yes == 1L
        message("Search in geofabrik_zones$name for a closer match.")
        return(NULL)
      }
    } else {
      message("Nearest match to geofabrik_zones$name is greater than threshold distance")
      return(NULL)
    }
  }
  geofabrik_matches
}
#' Find geofabrik zones based on sf or sfc object
#'
#' @inheritParams get_geofabrik
#'
#' @return A data frame representing the matching items from the Geofabrik website
#' @export
#'
#' @examples
#' name = sf::st_sfc(sf::st_point(c(0, 53)), crs = 4326)
#' gf_find_sf(name)
gf_find_sf = function(name, ask = FALSE, op = sf::st_contains) {
  # sel_within = lengths(sf::st_within(name, geofabrik_zones)) > 0
  geofabrik_all_matches = geofabrik_zones[name, , op = op]
  if(nrow(geofabrik_all_matches) == 0) {
    message("The object is not within any geofrabrik zones, aborting")
    return(NULL)
  }

  geofabrik_matches = geofabrik_all_matches[which.max(geofabrik_all_matches$level), ]
  message(
    "The place is within these geofabrik zones: ",
    paste0(geofabrik_all_matches$name, collapse = ", "),
    "\nSelecting the smallest: ", geofabrik_matches$name
  )

  geofabrik_matches
}
