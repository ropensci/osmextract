#' Import a road network according to a specific mode of transport
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
#' @details TODO (precisely describe the function) Also slightly underline the
#'   differnces between legal access and convenience (i.e. these are not the
#'   best paths, just all available paths)
#'
#' @seealso [`oe_get()`]
#'
#' @examples
#' its_walking = oe_get_network("ITS Leeds", mode = "walking", quiet = TRUE)
#' plot(its_walking["highway"], lwd = 2, key.pos = 4, key.width = lcm(2.75))
#' its_driving = oe_get_network("ITS Leeds", mode = "driving", quiet = TRUE)
#' plot(its_driving["highway"], lwd = 2, key.pos = 4, key.width = lcm(2.75))
oe_get_network = function(
  place,
  mode = c("cycling", "driving", "walking"),
  ...
) {
  # Load the relevant oe_get options
  mode = match.arg(mode)
  oe_get_options = switch(
    mode,
    cycling = load_options_cycling(place),
    walking = load_options_walking(place),
    driving = load_options_driving(place)
  )

  # Check the other arguments supplied by the user
  dots_args = list(...)
  oe_get_options = check_args_network(dots_args, oe_get_options)

  # Run oe_get
  do.call(oe_get, oe_get_options)
}

# The following functions are used to load several ad-hoc vectortranslate
# options according to a specific mode of transport. The choices are documented
# in oe_get_network() and are based on the following documents:
# https://wiki.openstreetmap.org/wiki/OSM_tags_for_routing/Access_restrictions
# and https://wiki.openstreetmap.org/wiki/Key:access plus the discussion in
# https://github.com/ropensci/osmextract/issues/153

# According to the first document mentioned above (i.e. the OSM tags for
# routing), there are some default values that are not official nor generally
# accepted but have support among many mappers. More precise options are defined
# by other tags.

# See also: https://wiki.openstreetmap.org/wiki/Bicycle#Bicycle_Restrictions
# A cycling mode of transport includes the following scenarios:
# - highway IS NOT NULL (since usually that means that's not a road) AND highway
# NOT IN ('abandoned', 'bus_guideway', 'byway', 'construction', 'corridor',
# 'elevator', 'fixme', 'escalator', 'gallop', 'historic', 'no', 'planned',
# 'platform', 'proposed', 'raceway', 'steps') OR
# highway IN ('motorway', 'motorway_link', 'bridleway', 'footway', 'pedestrian) AND bicycle = 'yes'
# - access IS NULL OR access NOT IN ('no', 'private') OR bicycle = yes;
# - bicycle IS NULL OR bicycle NOT IN ('no', 'use_sidepath')
# - service IS NULL OR service does not look like 'private' (ILIKE is string
# matching case insensitive)
load_options_cycling = function(place) {
  list(
    place = place,
    layer = "lines",
    extra_tags = c("access", "bicycle", "service"),
    vectortranslate_options = c(
    "-where", "
    ((highway IS NOT NULL AND highway NOT IN (
    'abandonded', 'bus_guideway', 'byway', 'construction', 'corridor', 'elevator',
    'fixme', 'escalator', 'gallop', 'historic', 'no', 'planned', 'platform',
    'proposed', 'raceway', 'steps'
    )) OR (
    highway IN ('motorway', 'motorway_link', 'footway',
    'bridleway', 'pedestrian') AND bicycle = 'yes'
    ))
    AND
    (access IS NULL OR access NOT IN ('private', 'no') OR bicycle = 'yes')
    AND
    (bicycle IS NULL OR bicycle NOT IN ('no', 'use_sidepath'))
    AND
    (service IS NULL OR service NOT ILIKE 'private')
    "
    )
  )
}

# See also https://wiki.openstreetmap.org/wiki/Key:footway and
# https://wiki.openstreetmap.org/wiki/Key:foot
# A walking mode of transport includes the following scenarios:
# - highway IS NOT NULL (since usually that means that's not a road) AND highway
# NOT IN ('abandoned', 'bus_guideway', 'byway', 'construction', 'corridor',
# 'elevator', 'fixme', 'escalator', 'gallop', 'historic', 'no', 'planned',
# 'platform', 'proposed', 'raceway', 'motorway', 'motorway_link') OR
# highway =('cycleway' AND foot = 'yes'
# - access IS NULL OR access NOT IN ('no', 'private') OR foot = yes;
# - foot IS NULL OR foot NOT IN ('no', 'use_sidepath', 'private', 'restricted')
# - service IS NULL OR service does not look like 'private' (ILIKE is string
# matching case insensitive)
load_options_walking = function(place) {
  list(
    place = place,
    layer = "lines",
    extra_tags = c("access", "foot", "service"),
    vectortranslate_options = c(
    "-where", "
    ((highway IS NOT NULL AND highway NOT IN (
    'abandonded', 'bus_guideway', 'byway', 'construction', 'corridor', 'elevator',
    'fixme', 'escalator', 'gallop', 'historic', 'no', 'planned', 'platform',
    'proposed', 'raceway', 'motorway', 'motorway_link'
    )) OR (
    highway = 'cycleway' AND foot = 'yes'
    ))
    AND
    (access IS NULL OR access NOT IN ('private', 'no') OR foot = 'yes')
    AND
    (foot IS NULL OR foot NOT IN ('private', 'no', 'use_sidepath', 'restricted'))
    AND
    (service IS NULL OR service NOT ILIKE 'private')
    "
    )
  )
}

# A motorcar/motorcycle mode of transport includes the following scenarios:
# - highway IS NOT NULL (since usually that means that's not a road) AND highway
# NOT IN ('bus_guideway', 'byway' (not sure what it means), 'construction',
# 'corridor', 'cycleway', 'elevator', 'fixme', 'footway', 'gallop', 'historic',
# 'no', 'pedestrian', 'platform', 'proposed', 'steps', 'pedestrian',
# 'bridleway', 'path', 'platform');
load_options_driving = function(place) {
  list(
    place = place,
    layer = "lines",
    extra_tags = c("access", "service"),
    vectortranslate_options = c(
    "-where", "
    highway IS NOT NULL
    AND
    highway NOT IN (
    'abandonded', 'bus_guideway', 'byway', 'construction', 'corridor', 'elevator',
    'fixme', 'escalator', 'gallop', 'historic', 'no', 'planned', 'platform',
    'proposed', 'cycleway', 'pedestrian', 'bridleway', 'path', 'footway'
    )
    AND
    (access IS NULL OR access NOT IN ('private', 'no'))
    AND
    (service IS NULL OR service NOT ILIKE 'private')
    "
    )
  )
}

# The following function is used to merge the vectortranslate options set by the
# mode of transport and the other oe_get options set by the user.
check_args_network = function(dots_args, oe_get_options) {
  # Check if the user set any argument in the call. If not, just return.
  if (length(dots_args) == 0L) {
    return(oe_get_options)
  }

  # Check the layer argument. At the moment we support only the lines layer
  if (!is.null(dots_args[["layer"]]) && dots_args[["layer"]] != "lines") {
    warning(
      "oe_get_network() works only with lines layer. Ignoring other values",
      call. = FALSE
    )
    # Remove the layer
    dots_args[["layer"]] = NULL
  }

  # Check the extra_tags argument and add all necessary values
  if (!is.null(dots_args[["extra_tags"]])) {
    oe_get_options[["extra_tags"]] = unique(
      c(oe_get_options[["extra_tags"]], dots_args[["extra_tags"]])
    )
    dots_args[["extra_tags"]] = NULL
  }

  # Check the vectortranslate_options argument and the -where keyword
  if (!is.null(dots_args[["vectortranslate_options"]])) {
    if ("-where" %in% dots_args[["vectortranslate_options"]]) {
      # Raise an error since -where arg must be set by the function
      stop(
        "The vectortranslate_options inside oe_get_network() cannot be used",
        "to define a query with the -where argument. Use the query argument",
        call. = FALSE
      )
    }
    # Otherwise append the two vectors
    oe_get_options[["vectortranslate_options"]] = c(
      oe_get_options[["vectortranslate_options"]], dots_args[["vectortranslate_options"]]
    )

    # Delete the value
    dots_args[["vectortranslate_options"]] = NULL
  }

  # Bind the two lists
  oe_get_options = c(oe_get_options, dots_args)

  # Return
  oe_get_options
}
