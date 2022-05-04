#' Import transport networks used by a specific mode of transport
#'
#' This function is a wrapper around `oe_get()` and can be used to import a road
#' network given a `place` and a mode of transport. Check the Details for a
#' precise description of the procedures used to filter the OSM ways according
#' to each each mode of transport.
#'
#' @inheritParams oe_get
#' @param mode A character string of length one denoting the desired mode of
#'   transport. Can be abbreviated. Currently `cycling` (the default), `driving`
#'   and `walking` are supported.
#' @param ... Additional arguments passed to `oe_get()` such as `boundary` or
#'   `force_download`.
#'
#' @return An `sf` object.
#' @export
#'
#' @details The definition of usable transport network was taken from the Python
#'   packages
#'   [osmnx](https://github.com/gboeing/osmnx/blob/main/osmnx/downloader.py) and
#'   [pyrosm](https://pyrosm.readthedocs.io/en/latest/) and several other
#'   documents found online, i.e.
#'   <https://wiki.openstreetmap.org/wiki/OSM_tags_for_routing/Access_restrictions>,
#'    <https://wiki.openstreetmap.org/wiki/Key:access>. See also the discussion
#'   in <https://github.com/ropensci/osmextract/issues/153>.
#'
#'   The `cycling` mode of transport (i.e. the default value for `mode`
#'   parameter) selects the OSM ways that meet the following conditions:
#'
#'   - The `highway` tag is not missing;
#'   - The `highway` tag is not equal to `abandoned`, `bus_guideway`, `byway`,
#'   `construction`, `corridor`, `elevator`, `fixme`, `escalator`, `gallop`,
#'   `historic`, `no`, `planned`, `platform`, `proposed`, `raceway` or
#'   `steps`;
#'   - The `highway` tag is not equal to `motorway`, `motorway_link`,
#'   `footway`, `bridleway` or `pedestrian` unless the tag `bicycle` is equal
#'   to `yes`, `designated`, `permissive` or `destination` (see
#'   [here](https://wiki.openstreetmap.org/wiki/Bicycle#Bicycle_Restrictions)
#'   for more details);
#'   - The `access` tag is not equal to `private` or `no`;
#'   - The `bicycle` tag is not equal to `no`, `use_sidepath`, `private`, or
#'   `restricted`;
#'   - The `service` tag does not contain the string `private` (i.e.
#'   `private`, `private_access` and similar);
#'
#'   The `walking` mode of transport selects the OSM ways that meet the
#'   following conditions:
#'
#'   - The `highway` tag is not missing;
#'   - The `highway` tag is not equal to `abandoned`, `bus_guideway`,
#'   `byway`, `construction`, `corridor`, `elevator`, `fixme`,
#'   `escalator`, `gallop`, `historic`, `no`, `planned`, `platform`, `proposed`,
#'   `raceway`, `motorway` or `motorway_link`;
#'   - The `highway` tag is not equal to `cycleway` unless the `foot` tag is
#'   equal to `yes`;
#'   - The `access` tag is not equal to `private` or `no`;
#'   - The `foot` tag is not equal to `no`, `use_sidepath`, `private`, or
#'   `restricted`;
#'   - The `service` tag does not contain the string `private`
#'   (i.e. `private`, `private_access` and similar).
#'
#'   The `driving` mode of transport selects the OSM ways that meet the
#'   following conditions:
#'
#'   - The `highway` tag is not missing;
#'   - The `highway` tag is not equal to `abandoned`,
#'   `bus_guideway`, `byway`, `construction`, `corridor`, `elevator`, `fixme`,
#'   `escalator`, `gallop`, `historic`, `no`, `planned`, `platform`, `proposed`,
#'   `cycleway`, `pedestrian`, `bridleway`, `path`, or `footway`;
#'   - The `access` tag is not equal to `private` or `no`;
#'   - The `service` tag does not contain the string `private` (i.e. `private`,
#'   `private_access` and similar).
#'
#'   Feel free to create a new issue in the [github
#'   repo](https://github.com/ropensci/osmextract) if you want to suggest
#'   modifications to the current filters or propose new values for alternative
#'   modes of transport.
#'
#' @seealso [oe_get()]
#'
#' @examples
#' # Copy the ITS file to tempdir() to make sure that the examples do not
#' # require internet connection. You can skip the next 4 lines (and start
#' # directly with oe_get_keys) when running the examples locally.
#'
#' its_pbf = file.path(tempdir(), "test_its-example.osm.pbf")
#' file.copy(
#'   from = system.file("its-example.osm.pbf", package = "osmextract"),
#'   to = its_pbf,
#'   overwrite = TRUE
#' )
#'
#' # default value returned by OSM
#' its = oe_get(
#'   "ITS Leeds", quiet = TRUE, download_directory = tempdir()
#' )
#' plot(its["highway"], lwd = 2, key.pos = 4, key.width = lcm(2.75))
#' # walking mode of transport
#' its_walking = oe_get_network(
#'   "ITS Leeds", mode = "walking",
#'   download_directory = tempdir(), quiet = TRUE
#' )
#' plot(its_walking["highway"], lwd = 2, key.pos = 4, key.width = lcm(2.75))
#' # driving mode of transport
#' its_driving = oe_get_network(
#'   "ITS Leeds", mode = "driving",
#'   download_directory = tempdir(), quiet = TRUE
#' )
#' plot(its_driving["highway"], lwd = 2, key.pos = 4, key.width = lcm(2.75))
#'
#' # Remove .pbf and .gpkg files in tempdir
#' oe_clean(tempdir())
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
    driving = load_options_driving(place),
    walking = load_options_walking(place)
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
# https://github.com/ropensci/osmextract/issues/153 and https://github.com/udsleeds/openinfra/issues/32

# According to the first document mentioned above (i.e. the OSM tags for
# routing), there are some default values that are not official nor generally
# accepted but have support among many mappers. More precise options are defined
# by other tags. See also: https://wiki.openstreetmap.org/wiki/Bicycle#Bicycle_Restrictions

# A cycling mode of transport includes the following scenarios:
# - highway IS NOT NULL (since usually that means that's not a road);
# - highway NOT IN ('abandoned', 'bus_guideway', 'byway', 'construction', 'corridor',
# 'elevator', 'fixme', 'escalator', 'gallop', 'historic', 'no', 'planned',
# 'platform', 'proposed', 'raceway', 'steps');
# - highway NOT IN IN ('motorway', 'motorway_link', 'bridleway', 'footway',
# 'pedestrian) OR bicycle IN ('yes', 'designated', 'permissive', 'destination');
# - access NOT IN ('no', 'private');
# - bicycle NOT IN ('no', 'use_sidepath')
# - service does not look like 'private' (ILIKE is string matching case insensitive)
load_options_cycling = function(place) {
  list(
    place = place,
    layer = "lines",
    extra_tags = c("access", "bicycle", "service"),
    vectortranslate_options = c(
    "-where", "
    (highway IS NOT NULL)
    AND
    (highway NOT IN (
    'abandoned', 'bus_guideway', 'byway', 'construction', 'corridor', 'elevator',
    'fixme', 'escalator', 'gallop', 'historic', 'no', 'planned', 'platform',
    'proposed', 'raceway', 'steps'
    ))
    AND
    (highway NOT IN ('motorway', 'motorway_link', 'footway', 'bridleway',
    'pedestrian') OR bicycle IN ('yes', 'designated', 'permissive', 'destination')
    )
    AND
    (access NOT IN ('private', 'no'))
    AND
    (bicycle NOT IN ('private', 'no', 'use_sidepath', 'restricted'))
    AND
    (service NOT ILIKE 'private%')
    "
    )
  )
}

# See also https://wiki.openstreetmap.org/wiki/Key:footway and
# https://wiki.openstreetmap.org/wiki/Key:foot
# A walking mode of transport includes the following scenarios:
# - highway IS NOT NULL (since usually that means that's not a road);
# - highway NOT IN ('abandoned', 'bus_guideway', 'byway', 'construction', 'corridor',
# 'elevator', 'fixme', 'escalator', 'gallop', 'historic', 'no', 'planned',
# 'platform', 'proposed', 'raceway', 'motorway', 'motorway_link');
# - highway != 'cycleway' OR foot IN ('yes', 'designated', 'permissive', 'destination');
# - access NOT IN ('no', 'private');
# - foot NOT IN ('no', 'use_sidepath', 'private', 'restricted')
# - service does not look like 'private' (ILIKE is string matching case insensitive)
load_options_walking = function(place) {
  list(
    place = place,
    layer = "lines",
    extra_tags = c("access", "foot", "service"),
    vectortranslate_options = c(
    "-where", "
    (highway IS NOT NULL)
    AND
    (highway NOT IN ('abandoned', 'bus_guideway', 'byway', 'construction', 'corridor', 'elevator',
    'fixme', 'escalator', 'gallop', 'historic', 'no', 'planned', 'platform', 'proposed', 'raceway',
    'motorway', 'motorway_link'))
    AND
    (highway <> 'cycleway' OR foot IN ('yes', 'designated', 'permissive', 'destination'))
    AND
    (access NOT IN ('private', 'no'))
    AND
    (foot NOT IN ('private', 'no', 'use_sidepath', 'restricted'))
    AND
    (service NOT ILIKE 'private%')
    "
    )
  )
}

# A motorcar/motorcycle mode of transport includes the following scenarios:
# - highway IS NOT NULL (since usually that means that's not a road);
# - highway NOT IN ('bus_guideway', 'byway' (not sure what it means), 'construction',
# 'corridor', 'cycleway', 'elevator', 'fixme', 'footway', 'gallop', 'historic',
# 'no', 'pedestrian', 'platform', 'proposed', 'steps', 'pedestrian',
# 'bridleway', 'path', 'platform');
# - access NOT IN ('private', 'no');
# - service NOT ILIKE 'private%';
load_options_driving = function(place) {
  list(
    place = place,
    layer = "lines",
    extra_tags = c("access", "service"),
    vectortranslate_options = c(
    "-where", "
    (highway IS NOT NULL)
    AND
    (highway NOT IN (
    'abandoned', 'bus_guideway', 'byway', 'construction', 'corridor', 'elevator',
    'fixme', 'escalator', 'gallop', 'historic', 'no', 'planned', 'platform',
    'proposed', 'cycleway', 'pedestrian', 'bridleway', 'path', 'footway',
    'steps'
    ))
    AND
    (access NOT IN ('private', 'no'))
    AND
    (service NOT ILIKE 'private%')
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
