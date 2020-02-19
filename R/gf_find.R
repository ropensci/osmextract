#' Find osmextractr zones
#'
#' @inheritParams get_osmextractr
#'
#' @return A data frame representing the matching items from the Geofabrik website
#' @export
#'
#' @examples
#' gf_find("Andorra")
gf_find = function(name, ask = FALSE, max_dist = 5) {

  matching_dist = as.numeric(utils::adist(osmextractr_zones$name, name))
  best_match = which.min(matching_dist)
  osmextractr_matches = osmextractr_zones[best_match, ]
  high_distance = matching_dist[best_match] > max_dist
  if(high_distance) {
    message("No exact matching osmextractr zone. Best match is ", osmextractr_matches$name, " ", osmextractr_matches$size_pbf)
    if(interactive() & ask) {
      continue = utils::menu(choices = c("Yes", "No"), title = "Would you like to download this file?")
      if(continue != 1L) {# since the options are Yes/No, then Yes == 1L
        message("Search in osmextractr_zones$name for a closer match.")
        return(NULL)
      }
    } else {
      message("Nearest match to osmextractr_zones$name is greater than threshold distance")
      return(NULL)
    }
  }
  osmextractr_matches
}
#' Find osmextractr zones based on sf or sfc object
#'
#' @inheritParams get_osmextractr
#'
#' @return A data frame representing the matching items from the Geofabrik website
#' @export
#'
#' @examples
#' name = sf::st_sfc(sf::st_point(c(0, 53)), crs = 4326)
#' gf_find_sf(name)
gf_find_sf = function(name, ask = FALSE, op = sf::st_contains) {
  # sel_within = lengths(sf::st_within(name, osmextractr_zones)) > 0
  osmextractr_all_matches = osmextractr_zones[name, , op = op]
  if(nrow(osmextractr_all_matches) == 0) {
    message("The object is not within any geofrabrik zones, aborting")
    return(NULL)
  }

  osmextractr_matches = osmextractr_all_matches[which.max(osmextractr_all_matches$level), ]
  message(
    "The place is within these osmextractr zones: ",
    paste0(osmextractr_all_matches$name, collapse = ", "),
    "\nSelecting the smallest: ", osmextractr_matches$name
  )

  osmextractr_matches
}
