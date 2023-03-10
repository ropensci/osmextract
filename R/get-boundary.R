#' Get the administrative boundary for a given place
#'
#' This function can be used to obtain polygon/multipolygon objects representing
#' an administrative boundary. The objects are extracted from the
#' `multipolygons` layer of a given OSM extract.
#'
#' The function may return an empty result when the corresponding GPKG file
#' already exists and contains partial results. In that case, you can try
#' running the function setting `never_skip_vectortranslate = TRUE`.
#'
#' @inheritParams oe_get
#' @param name A character vector of length 1 that describes the relevant area.
#'   By default, this is equal to `place`, but this parameter can be tuned to
#'   obtain more granular results starting from the same OSM extract. See
#'   examples. It must be always set when the `place` argument is specified
#'   using numeric or spatial objects.
#' @param exact Boolean of length 1. If `TRUE`, then the function returns only
#'   those features where the field `name` is exactly equal to `name`. If
#'   `FALSE`, it performs a (case-sensitive) pattern matching.
#' @param ... Further arguments (e.g. `quiet` or `force_vectortranslate`) that
#'   are passed to `oe_get()`.
#'
#' @return An `sf` object
#' @export
#'
#' @examples
#' \dontrun{
#' library(sf)
#' my_cols = sf.colors(5, categorical = TRUE)
#' gabon = oe_get_boundary("Gabon", quiet = TRUE) # country
#' libreville = oe_get_boundary("Gabon", "Libreville", quiet = TRUE) # capital
#'
#' opar = par(mar = rep(0, 4))
#' plot(st_geometry(st_boundary(gabon)), reset = FALSE, col = "grey")
#' plot(st_geometry(libreville), add = TRUE, col = my_cols[1])
#'
#' # Exact match
#' komo = oe_get_boundary("Gabon", "Komo", quiet = TRUE)
#' # Pattern matching
#' komo_pt = oe_get_boundary("Gabon", "Komo", exact = FALSE, quiet = TRUE)
#' plot(st_geometry(komo), add = TRUE, col = my_cols[2])
#' plot(st_geometry(komo_pt), add = TRUE, col = my_cols[3:5])
#' par(opar)
#'
#' # Get all boundaries
#' (oe_get_boundary("Gabon", name = "%", exact = FALSE, quiet = TRUE)[, 1:2])
#'
#' # If the basic approach doesn't work, i.e.
#' oe_get_boundary("Leeds")
#'
#' # try to consider larger regions, i.e.
#' oe_get_boundary("West Yorkshire", "Leeds")
#' }

oe_get_boundary <- function(
    place,
    name = place,
    exact = TRUE,
    ...
) {
  if (length(name) != 1L || !is.character(name)) {
    oe_stop(
      .subclass = "osmext-name-get-boundary",
      message = "The name argument must be a character vector of length one."
    )
  }

  boundary_query = ifelse(
    exact,
    paste0("SELECT * FROM multipolygons WHERE type = 'boundary' AND boundary = 'administrative' AND name = '", name, "'"),
    paste0("SELECT * FROM multipolygons WHERE type = 'boundary' AND boundary = 'administrative' AND name LIKE '%", name, "%'")
  )
  oe_get(
    place = place,
    query = boundary_query,
    ...
  )
}
