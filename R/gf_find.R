#' Find geofabric zones
#'
#' @inheritParams get_geofabric
#'
#' @return A data frame representing the matching items from the Geofabrik website
#' @export
#'
#' @examples
#' gf_find("Andorra")
gf_find = function(name, ask = FALSE, max_dist = 3) {

  matching_dist = as.numeric(utils::adist(geofabric_zones$name, name))
  best_match = which.min(matching_dist)
  geofabric_matches = geofabric_zones[best_match, ]
  high_distance = matching_dist[best_match] > max_dist
  message("No exact matching geofabric zone. Best match is ", geofabric_matches$name, " ", geofabric_matches$size_pbf)
  if(interactive() & ask & high_distance) {
    continue = utils::menu(choices = c("Yes", "No"), title = "Would you like to download this file?")
    if(continue != 1L) {# since the options are Yes/No, then Yes == 1L
      stop("Search in geofabric_zones for a closer match.")
    }
  }
  geofabric_matches
}
#' Find geofabric zones based on sf or sfc object
#'
#' @inheritParams get_geofabric
#'
#' @return A data frame representing the matching items from the Geofabrik website
#' @export
#'
#' @examples
#' name = sf::st_sfc(sf::st_point(c(0, 53)), crs = 4326)
#' gf_find_sf(name)
gf_find_sf = function(name, ask = FALSE, op = sf::st_contains) {
  sel_within = lengths(sf::st_within(name, geofabric_zones)) > 0
  geofabric_all_matches = geofabric_zones[name, , op = op]
  if(nrow(geofabric_all_matches) == 0) {
    message("The object is not within any geofrabric zones, aborting")
    return(NULL)
  }

  geofabric_matches = geofabric_all_matches[which.max(geofabric_matches$level), ]
  message(
    "The place is within these geofabrik zones: ",
    paste0(geofabric_all_matches$name, collapse = ", "),
    "\nSelecting the smallest: ", geofabric_matches$name)

  geofabric_matches
}
