#' Obtain a sfnetwork object from OpenStreetMap data
#'
#' This function is a wrapper around `oe_get_network()` that returns a
#' `sfnetwork` object. It performs simplification of the highway values and
#' filters by highway types if specified. Minimal network preprocessing tasks
#' i.e. subdivision and smoothing are performed. It also allows for the creation
#' of directed or undirected networks.
#'
#' @inheritParams oe_get_network
#' @param ... Additional arguments passed to [oe_get_network()].
#' @param directed logical, whether to return a directed sfnetwork object
#'   (default is `FALSE`)
#' @param require_equal logical or character vector. Defaults to `TRUE.` If
#'   `TRUE`, only pseudo nodes that have incident edges with equal attribute
#'   values are removed. Alternatively, a character vector with the names of the
#'   attributes to check for equality can be provided. In that case, only those
#'   attributes are checked for equality. If `FALSE`, all pseudo nodes are
#'   removed regardless of attribute values. All other attributes are collapsed,
#'   separating the values by a comma.
#' @inheritParams oe_get
#'
#' @returns An `sfnetwork` object
#'
#' @details
#'
#' In particular, the two preprocessing morphers applied to the output returned
#' by [oe_get_network()] are [sfnetworks::to_spatial_subdivision()] and
#' [sfnetworks::to_spatial_smooth()]. Check their help pages for more details.
#' See also the documentation for `sfnetworks` for more details on the two
#' preprocessing steps: [subdividing
#' edges](https://luukvdmeer.github.io/sfnetworks/articles/sfn02_preprocess_clean.html#subdivide-edges)
#' and [smoothing
#' pseudo-nodes](https://luukvdmeer.github.io/sfnetworks/articles/sfn02_preprocess_clean.html#smooth-pseudo-nodes).
#'
#' Note that preprocessing is performed on the undirected graph, ignoring road
#' directionality. If `directed = TRUE`, the function then builds the directed
#' graph by duplicating bidirectional edges with reversed geometries. If the
#' `oneway` column is missing, a warning is issued and an undirected `sfnetwork`
#' is returned instead.
#'
#' @export
#'
#' @seealso [oe_get()], [oe_get_network()], [oe_get_dodgrnetwork()]
#' @examples
#' # Copy the ITS file to tempdir() to make sure that the examples do not
#' # require internet connection. You can skip the next 4 lines (and start
#' # directly with oe_get_keys) when running the examples locally.
#' its_pbf = file.path(tempdir(), "test_its-example.osm.pbf")
#' file.copy(
#'   from = system.file("its-example.osm.pbf", package = "osmextract"),
#'   to = its_pbf,
#'   overwrite = TRUE
#' )
#' if (requireNamespace("sfnetworks", quietly = TRUE)) {
#'   #' # Undirected unfiltered pedestrian network
#'   walk_sfnet <- oe_get_sfnetwork(
#'     place = "ITS Leeds",
#'     mode = "walking",
#'     download_directory = tempdir(),
#'     quiet = TRUE
#'   )
#'   plot(walk_sfnet)
#'
#'   #' # Directed unfiltered driving network
#'   car_sfnet <- oe_get_sfnetwork(
#'     place = "ITS Leeds",
#'     mode = "driving",
#'     directed = TRUE,
#'     download_directory = tempdir(),
#'     quiet = TRUE
#'   )
#'   plot(car_sfnet)
#'
#'   #' # Directed filtered driving network
#'   highway_filter = c(
#'     "motorway",
#'     "trunk",
#'     "primary",
#'     "secondary",
#'     "tertiary",
#'     "unclassified",
#'     "residential"
#'   )
#'
#'   car_sfnet_filtered <- oe_get_sfnetwork(
#'     place = "ITS Leeds",
#'     mode = "driving",
#'     directed = TRUE,
#'     highway_filter = highway_filter,
#'     download_directory = tempdir(),
#'     quiet = TRUE
#'   )
#'   plot(car_sfnet_filtered)
#'
#'   # Smooth pseudo nodes when highway and oneway fields are equal
#'   car_sfnet_filtered_2 <- oe_get_sfnetwork(
#'     place = "ITS Leeds",
#'     mode = "driving",
#'     directed = TRUE,
#'     highway_filter = highway_filter,
#'     require_equal = c("highway", "oneway"),
#'     download_directory = tempdir(),
#'     quiet = TRUE
#'   )
#'   plot(car_sfnet_filtered_2)
#' }
oe_get_sfnetwork = function(
  place,
  mode = c("cycling", "driving", "walking"),
  ...,
  require_equal = TRUE,
  directed = FALSE,
  highway_filter = NULL,
  quiet = FALSE
) {
  # Preprocessing args
  if (!is.null(highway_filter)) {
    check_highway_filter(highway_filter)
  }
  stopifnot(is.logical(directed), length(directed) == 1L)
  args = list(...)
  mode = match.arg(mode)

  # Setup oe_get_network call
  cleannetargs = c(
    list(
      place = place,
      mode = mode
    ),
    args,
    list(
      quiet = quiet,
      clean_output = TRUE,
      highway_filter = highway_filter
    )
  )
  net = do.call(oe_get_network, cleannetargs)

  # Basic simplification using sfnetworks with the undirected graph
  oe_message(
    "Starting basic network pre-processing. This can take a few minutes for large networks...",
    quiet = quiet,
    .subclass = "oe_get_sfnetwork_simplification"
  )
  net = net_2_sfnet_undirected(net, require_equal = require_equal)

  if (directed && "oneway" %!in% names(sf::st_as_sf(net, "edges"))) {
    warning(
      paste(
        "The", sQuote("oneway"), "column is missing.",
        sQuote("directed"),
        "will be forced to FALSE and an undirected sfnetwork will be returned"
      )
    )
    directed = FALSE
  }

  if (directed) {
    # Prepare directed graph
    net = prepare_directed(net)
  }

  net
}

#' Convert a spatial network to an undirected sfnetwork
#'
#' @param net_sf a `sf` object representing a spatial network
#' @param require_equal logical or character vector. Defaults to `TRUE`. If
#'   `TRUE`, only pseudo nodes that have incident edges with all equal attribute
#'   values are removed. Alternatively, a character vector with the names of the
#'   attributes to check for equality can be provided. In that case, only those
#'   attributes are checked for equality. If `FALSE`, all pseudo nodes are
#'   removed regardless of attribute values. All other attributes are collapsed
#'   separated by a comma.
#'
#' @returns An `sfnetwork` object
#' @export
#'
#' @examples
#' # Copy the ITS file to tempdir() to make sure that the examples do not
#' # require internet connection. You can skip the next 4 lines (and start
#' # directly with oe_get_keys) when running the examples locally.
#' its_pbf = file.path(tempdir(), "test_its-example.osm.pbf")
#' file.copy(
#'   from = system.file("its-example.osm.pbf", package = "osmextract"),
#'   to = its_pbf,
#'   overwrite = TRUE
#' )
#'
#' net_sf <- oe_get_network(
#'   place = "ITS Leeds",
#'   mode = "driving",
#'   clean_output = TRUE,
#'   download_directory = tempdir(),
#'   quiet = TRUE
#' )
#'
#' if (requireNamespace("sfnetworks", quietly = TRUE)) {
#'   sfnet_undirected <- net_2_sfnet_undirected(net_sf)
#'   plot(sfnet_undirected)
#' }
net_2_sfnet_undirected = function(net_sf, require_equal = TRUE) {
  if (!requireNamespace("sfnetworks", quietly = TRUE)) {
    stop("sfnetworks is not available. Please install it first")
  }

  stopifnot(
    (is.logical(require_equal) && length(require_equal) == 1L) ||
      (is.character(require_equal) && all(require_equal %in% names(net_sf)))
  )

  sfnet = sfnetworks::as_sfnetwork(
    x = net_sf,
    directed = FALSE
  )

  # Creating junctions where road segments overlap
  # This converts implicit intersections into explicit nodes
  sf_net_subdiv = tidygraph::convert(sfnet, sfnetworks::to_spatial_subdivision, .clean = TRUE)

  # Simplifying the interstitial nodes segments
  tidygraph::convert(
    sf_net_subdiv,
    sfnetworks::to_spatial_smooth,
    summarise_attributes = list(collapse_function),
    require_equal = require_equal,
    .clean = TRUE
  )
}

prepare_directed = function(sfnet_und) {
  if (!requireNamespace("sfnetworks", quietly = TRUE)) {
    stop("sfnetworks is not available. Please install it first")
  }

  net_raw = sfnetworks::activate(sfnet_und, "edges") |>
    sf::st_as_sf()

  net_raw$from = NULL
  net_raw$to = NULL
  net_raw$z_order = NULL

  # Reversing the geometries of bidirectional links
  net_rev = sf::st_reverse(net_raw[net_raw$oneway == "no", ])

  # Binding the duplicated geometries
  if (requireNamespace("dplyr", quietly = TRUE)) {
    dplyr::bind_rows(net_rev, net_raw) |>
      sfnetworks::as_sfnetwork(directed = TRUE)
  } else {
    rbind(net_rev, net_raw) |>
      sfnetworks::as_sfnetwork(directed = TRUE)
  }
}

#' Obtain a dodgr_streetnet object from OpenStreetMap data
#'
#' This function is a wrapper around `oe_get_network()` that returns a
#' `dodgr_streetnet` object. It performs simplification of the highway values,
#' filters by highway types and standardises the `oneway` attribute as well as
#' applying the implied oneway restriction based on the `junction`` tag values.
#'
#' @inheritParams oe_get_sfnetwork
#' @inheritParams oe_get quiet
#' @param highway_filter Character vector of highway types to keep.  Ignored if
#'   `NULL`. Valid values are: "busway", "cycleway", "footway", "living_street",
#'   "motorway", "path", "pedestrian", "primary", "residential", "rest_area",
#'   "service", "services", "steps", "tertiary", "track", "trunk" and
#'   "unclassified".
#' @param ... additional parameters passed to [oe_get_network()] and
#'   [dodgr::weight_streetnet()], excluding `x` and `id_col` for the latter.
#'
#' @returns A `dodgr_streetnet` object
#'
#' @export
#'
#' @seealso [oe_get()], [oe_get_network()], [oe_get_sfnetwork()]
#'
#' @examples
#' # Copy the ITS file to tempdir() to make sure that the examples do not
#' # require internet connection. You can skip the next 4 lines (and start
#' # directly with oe_get_keys) when running the examples locally.
#' its_pbf = file.path(tempdir(), "test_its-example.osm.pbf")
#' file.copy(
#'   from = system.file("its-example.osm.pbf", package = "osmextract"),
#'   to = its_pbf,
#'   overwrite = TRUE
#' )
#'
#' if (requireNamespace("dodgr", quietly = TRUE)) {
#'   graph_bike <- oe_get_dodgrnetwork(
#'     place = "ITS Leeds",
#'     mode = "cycling",
#'     wt_profile = "bicycle",
#'     left_side = TRUE,
#'     download_directory = tempdir(),
#'     quiet = TRUE
#'   )
#'   head(graph_bike)
#'
#'   highway_filter = c(
#'     "motorway",
#'     "trunk",
#'     "primary",
#'     "secondary",
#'     "tertiary",
#'     "unclassified",
#'     "residential"
#'   )
#'
#'   graph_car <- oe_get_dodgrnetwork(
#'     place = "ITS Leeds",
#'     mode = "driving",
#'     wt_profile = "motorcar",
#'     left_side = TRUE,
#'     highway_filter = highway_filter,
#'     download_directory = tempdir(),
#'     quiet = TRUE
#'   )
#'
#'   head(graph_car)
#'   class(graph_car)
#' }
oe_get_dodgrnetwork = function(
  place,
  mode = c("cycling", "driving", "walking"),
  ...,
  highway_filter = NULL,
  quiet = FALSE
) {
  if (!requireNamespace("dodgr", quietly = TRUE)) {
    stop("dodgr is not available. Please install it first")
  }

  if (!is.null(highway_filter)) {
    check_highway_filter(highway_filter)
  }

  # Extract the dots arguments as a list
  all.args = list(...)

  # Identifying the names of the parameters for the dodgr function
  dodgr.pars = names(formals(dodgr::weight_streetnet))
  dodgr.pars = dodgr.pars[!dodgr.pars %in% c("x", "id_col")]

  # Get a subset of the all.args that are not in dodgr.pars
  current.args = all.args[!names(all.args) %in% c(dodgr.pars)]

  # Compile the arguments for the oe_get_network function, including the highway_filter
  cleannetargs = list(
    place = place,
    mode = mode,
    quiet = quiet,
    clean_output = TRUE,
    highway_filter = highway_filter
  )
  cleannetargs = c(cleannetargs, current.args)

  # Calling the oe_get_network function with the filtered arguments
  net = do.call(oe_get_network, cleannetargs)

  # Calling the dodgr::weight_streetnet function with the net and the remaining arguments
  dodgr_args = list(x = net)
  dodgr_args = c(dodgr_args, all.args[names(all.args) %in% dodgr.pars])

  if ("oneway" %!in% names(net)) {
    warning(
      paste(
        "The", sQuote("oneway"), "column is missing.",
        "All edges will be assumed to be bidirectional!"
      )
    )
  }

  # Returning the weighted_streetnetwork
  do.call(dodgr::weight_streetnet, dodgr_args)
}

## Utils

# This function simplifies the highway values by removing the "_link" suffix and
# filtering by `highway_filter` if specified.
clean_highway = function(net, highway_filter = NULL) {
  stopifnot("highway" %in% names(net))

  net$highway = gsub(
    pattern = "_link",
    replacement = "",
    x = net$highway
  )

  if (!is.null(highway_filter)) {
    net = net[net$highway %in% highway_filter, ]
  }
  net
}

#' Clean the oneway values in a OSM network
#'
#' This helper function standardises the oneway values in a OSM network. It also
#' applies a few implied `oneway` tag restriction based on the `junction` tag
#' values if specified and substitutes remaining `NA` values as `"no"`. See
#' Details.
#'
#' @param x a `sf` object representing a spatial network with the `oneway`
#'   and `junction` columns
#' @param quiet logical, whether to suppress messages. Default is `FALSE`.
#'
#' @export
#' @returns An `sf` object with standardised oneway values
#'
#' @details According to the information reported at
#'   [wiki.openstreetmap.org](https://wiki.openstreetmap.org/wiki/Key:oneway#Implied_oneway_restriction),
#'   the `oneway` key can only assume one out of 5 possible values: `"yes"`,
#'   `"no"`, `"-1"`, `"reversible"`, and `"alternating"`. However, the oneway
#'   tag is optional and typically missing. Hence, the objective of this
#'   function is to replace the `NA` values whenever possible using contextual
#'   information.
#'
#'   In fact, there are tags or combination of tags (such as
#'   junction='roundabout') which imply `oneway='yes'`. This function tests such
#'   combination and converts the NA values into 'yes'.
#'
#'   Then, the `oneway='-1'` values (which indicate wrong-way roads) are fixed
#'   by reversing the geometry of the lines and setting the road as oneway.
#'
#'   Finally, the remaining NA values are set as `oneway='no'`. For simplicity,
#'   even the `oneway='reversible'` and `oneway='alternating'` are converted
#'   into `oneway='no'`.
#'
#' @examples
#' # Copy the ITS file to tempdir() to make sure that the examples do not
#' # require internet connection. You can skip the next 4 lines (and start
#' # directly with oe_get_keys) when running the examples locally.
#' its_pbf = file.path(tempdir(), "test_its-example.osm.pbf")
#' file.copy(
#'   from = system.file("its-example.osm.pbf", package = "osmextract"),
#'   to = its_pbf,
#'   overwrite = TRUE
#' )
#' roads <- oe_get_network(
#'   place = "ITS Leeds",
#'   mode = "driving",
#'   download_directory = tempdir(),
#'   quiet = TRUE
#' )
#' table(roads$oneway, useNA = "ifany")
#' roads_clean <- clean_oneway(roads)
#' table(roads_clean$oneway, useNA = "ifany")
clean_oneway = function(x, quiet = FALSE) {
  stopifnot("oneway" %in% names(x))

  if ("junction" %in% names(x)) {
    idx_roundabout <- !is.na(x[["junction"]]) & x[["junction"]] == "roundabout" & is.na(x[["oneway"]])
    x[["oneway"]][idx_roundabout] = "yes"
  }

  # Reversing the geometries with -1
  idx_m1 <- !is.na(x[["oneway"]]) & x[["oneway"]] == "-1"
  sf::st_geometry(x[idx_m1, ]) = sf::st_reverse(sf::st_geometry(x[idx_m1, ]))

  x$oneway[idx_m1] = "yes"

  # Simplifying the bi-directional tags
  x$oneway[
    is.na(x$oneway) | x$oneway %in% c("alternating", "reversible")
  ] = "no"

  x
}

# Function for summarise attributes of edges when converting to sfnetwork
collapse_function = function(x) {
  paste(unique(x), collapse = ",")
}

# function to ensure that the string values match the possible values for the
# highway_filter parameter
check_highway_filter = function(highway_filter) {
  match.arg(
    highway_filter,
    c(
      "busway",
      "cycleway",
      "footway",
      "living_street",
      "motorway",
      "path",
      "pedestrian",
      "primary",
      "residential",
      "rest_area",
      "service",
      "services",
      "steps",
      "tertiary",
      "track",
      "trunk",
      "unclassified"
    ),
    several.ok = TRUE
  )
}
