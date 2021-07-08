#' Import a road network according to a specific mode of transport
#'
#' TODO
#'
#' @inheritParams oe_get
#' @param mode A character string denoting the desired mode of transport. Can be
#'   abbreviated.
#' @param ... IGNORED FOR THE MOMENT. Additional arguments passed to `oe_get()`.
#'   Please note that the arguments `layer` and `vectortranslate_options` cannot
#'   be provided since are set according to the `mode` parameter.
#'
#' @return An `sf` object.
#' @export
#'
#' @details TODO (precisely describe the function)
#'
#' @seealso [`oe_get()`]
#'
#' @examples
#' 1 + 1
oe_get_network <- function(
  place,
  mode = c("cycling", "walking"),
  ...
) {
  mode = match.arg(mode)
  oe_get_options = switch(
    mode,
    cycling = load_options_cycling(place, mode),
    walking = load_options_walking(place, mode)
  )

  do.call(oe_get, oe_get_options)
}

# List options that are used by oe_get_transport
load_options_cycling <- function(place, mode) {
  list(
    place = place,
    layer = "lines",
    extra_tags = c("access", "area", "bicycle", "service"),
    vectortranslate_options = c(
    "-where", "
    (area IS NULL OR area != 'yes')
    AND
    (access IS NULL OR access NOT IN ('private', 'no'))
    AND
    (highway IS NOT NULL AND
    highway NOT IN (
    'abandonded', 'bus_guideway', 'construction', 'corridor', 'elevator', 'escalator', 'footway',
    'planned', 'platform', 'proposed', 'raceway', 'steps'
    ))
    AND
    (bicycle IS NULL OR bicycle != 'no')
    AND
    (service IS NULL OR service != 'private')
    "
    )
  )
}
load_options_walking <- function(place, mode) {
  list(
    place = place,
    layer = "lines",
    extra_tags = c("access", "area", "foot", "service"),
    vectortranslate_options = c(
      "-where", "
    (area IS NULL OR area != 'yes')
    AND
    (access IS NULL OR access NOT IN ('private', 'no'))
    AND
    (highway IS NOT NULL AND
    highway NOT IN (
    'abandonded', 'bus_guideway', 'construction', 'cycleway',
    'planned', 'platform', 'proposed', 'raceway'
    ))
    AND
    (foot IS NULL OR foot != 'no')
    AND
    (service IS NULL OR service != 'private')
    "
    )
  )
}

