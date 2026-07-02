#' Obtain a sfnetwork object from OpenStreetMap data
#'
#' This function is a wrapper around `oe_get_network()` that returns a `sfnetwork` object.
#' It performs simplification of the highway values and filters by highway types if specified. Minimal
#' network preprocessing tasks i.e. subdivision and smoothing are performed using `sfnetworks` to
#' create a tidy `sfnetwork` object. All unique merged edge attributes are concatenated.
#' It also allows for the creation of directed or undirected networks.
#'
#' @param ... parameters passed to `oe_get_network()`
#' @param simplify_highway logical, whether to simplify the highway values by removing the "_link" suffix and filtering by `highway_filter`
#' @param highway_filter character vector of highway types to keep, if `simplify_highway` is TRUE
#' @param directed logical, whether to return a directed sfnetwork object (default is FALSE)
#'
#' @returns a `sfnetwork` object
#'
#' @export
#'
#' @seealso [oe_get()], [oe_get_network()], [oe_get_tidynetwork()], [oe_get_dodgrnetwork()]
#' @examples
#' highway_filter = c(
#'  "motorway",
#'  "trunk",
#'  "primary",
#'  "secondary",
#'  "tertiary",
#'  "unclassified",
#'  "residential"
#')
#'
#' # sfnet directed unfiltered
#' car_sfnet <- oe_get_sfnetwork(
#'   place = "ITS Leeds",
#'   mode = "driving",
#'   directed = TRUE
#' )
#' plot(car_sfnet)
#' # sfnet directed filtered
#' car_sfnet_filtered <- oe_get_sfnetwork(
#'   place = "ITS Leeds",
#'   mode = "driving",
#'   directed = TRUE,
#'   highway_filter = highway_filter
#' )
#'
#' # sfnet_undirected filtered
#' walk_sfnet <- oe_get_sfnetwork(
#'   place = "ITS Leeds",
#'   mode = "walking"
#' )
#' plot(walk_sfnet)
#'

oe_get_sfnetwork <- function(
    ...,
    directed = FALSE,
    simplify_highway = TRUE,
    highway_filter = NULL
) {
  rlang::check_installed(
    c("sfnetworks", "tidygraph"),
    reason = "to use the `oe_get_sfnetwork()` function."
  )

  if (!is.null(highway_filter)) {
    check_highway_filter(highway_filter)
  }

  if (!is.logical(directed) && length(directed) != 1) {
    stop(
      "The directed parameter must be a logical value (TRUE or FALSE)."
    )
  }

  net <- oe_get_tidynetwork(
    ...,
    simplify_highway = simplify_highway,
    highway_filter = highway_filter
  )

  # Basic simplification using sfnetworks with the undirected graph
  message("Starting basic network simplification...")
  net <- net_2_sfnet_undirected(net)

  if (directed) {
    # Prepare directed graph
    net <- prepare_directed(net)
  }

  net
}

#' Convert a spatial network to an undirected sfnetwork
#'
#' @param net_sf a `sf` object representing a spatial network
#'
#' @returns a `sfnetwork` object
#'
#' @examples
#' \dontrun{
#' net_sf <- oe_get_tidynetwork(place = "ITS Leeds", mode = "driving")
#'
#' sfnet_undirected <- net_2_sfnet_undirected(net_sf)
#' }
net_2_sfnet_undirected <- function(net_sf) {
  sfnet <- sfnetworks::as_sfnetwork(
    x = net_sf,
    directed = FALSE
  )

  # Creating junctions where road segments overlap
  # This converts implicit intersections into explicit nodes
  sf_net_subdiv <- tidygraph::convert(sfnet, sfnetworks::to_spatial_subdivision)

  # Simplifying the interstitial nodes segments keeping
  # the oneway attribute and concatenating the other fields

  tidygraph::convert(
    sf_net_subdiv,
    sfnetworks::to_spatial_smooth,
    summarise_attributes = list(collapse_function),
    require_equal = "oneway"
  )
}

prepare_directed <- function(sfnet_und) {
  net_raw <- sfnetworks::activate(sfnet_und, "edges") |>
    sf::st_as_sf()

  net_raw$from <- NULL
  net_raw$to <- NULL
  net_raw$z_order <- NULL

  # Reversing the geometries of bidirectional links
  net_rev <- sf::st_reverse(net_raw[net_raw$oneway == "no", ])

  # Binding the duplicated geometries
  rbind(net_rev, net_raw) |>
    sfnetworks::as_sfnetwork(directed = TRUE)
}

#' Obtain a tidy sf from OpenStreetMap data
#'
#' @inheritParams oe_get_sfnetwork
#'
#' @returns a `sf` object with standardised highway and oneway values
#'
#' @export
#'
#' @seealso [oe_get()], [oe_get_network()], [oe_get_sfnetwork()], [oe_get_dodgrnetwork()]
#' @examples
#'
#' highway_filter = c(
#'  "motorway",
#'  "trunk",
#'  "primary",
#'  "secondary",
#'  "tertiary",
#'  "unclassified",
#'  "residential"
#' )
#'
#' tidynet_sf <- oe_get_tidynetwork(place = "ITS Leeds", mode = "driving")
#' print(tidynet_sf)
#'
#' tidynet_sf_filtered <- oe_get_tidynetwork(
#'   place = "ITS Leeds",
#'   mode = "driving",
#'   highway_filter = highway_filter
#' )
#' print(tidynet_sf_filtered)
#'
oe_get_tidynetwork <- function(
    ...,
    simplify_highway = TRUE,
    highway_filter = NULL
) {
  if (!is.logical(simplify_highway) && length(simplify_highway) != 1) {
    stop(
      "The simplify_highway parameter must be a logical value (TRUE or FALSE)."
    )
  }

  if (!is.null(highway_filter)) {
    check_highway_filter(highway_filter)
  }

  args <- list(...)

  min_tags <- c("oneway", "junction")

  if ("extra_tags" %in% names(args)) {
    args$extra_tags <- c(args$extra_tags, min_tags)
  } else {
    args$extra_tags <- min_tags
  }

  # Get network
  net <- do.call(oe_get_network, args)

  # Tidy highway values
  if (simplify_highway) {
    net <- tidy_highway(net, highway_filter = highway_filter)
  }

  # Tidy oneway
  net <- tidy_oneway(net)

  net
}


#' Obtain a weighted_streetnet from OpenStreetMap data
#'
#' This function is a wrapper around `oe_get_network()`
#' that returns a `dodgr_streetnet`` object. It performs
#' simplification of the highway values, filters by highway types and
#' standardises the `oneway` attribute as well as applying the
#' implied oneway restriction based on the `junction`` tag values.
#'
#'
#'
#' @param ... parameters passed to `oe_get_network()` and `dodgr::weight_streetnet()`, excluding `x` and `id_col` for the latter.
#' @param highway_filter string vector of highway types to keep. By default, it includes "motorway", "trunk", "primary", "secondary", "tertiary", "unclassified", and "residential".
#'
#' @returns a `dodgr_streetnet` object
#'
#' @export
#'
#' @seealso [oe_get()], [oe_get_network()], [oe_get_sfnetwork()], [oe_get_sfnetwork()]
#'
#' @examples
#'  highway_filter = c(
#'  "motorway",
#'  "trunk",
#'  "primary",
#'  "secondary",
#'  "tertiary",
#'  "unclassified",
#'  "residential"
#' )
#'
#'  graph_car <- oe_get_dodgrnetwork(
#'    place = "ITS Leeds",
#'    mode = "driving",
#'    wt_profile = "motorcar",
#'    left_side = TRUE
#'  )
#'
#'  class(graph_car)
#'
#'  graph_bike <- oe_get_dodgrnetwork(
#'    place = "ITS Leeds",
#'    mode = "cycling",
#'    wt_profile = "bicycle",
#'    left_side = TRUE,
#'    highway_filter = highway_filter
#'  )
#'
oe_get_dodgrnetwork <- function(
    ...,
    highway_filter = NULL
) {
  rlang::check_installed(
    c("sfnetworks", "tidygraph"),
    reason = "to use the `oe_get_sfnetwork()` function."
  )

  if (!is.null(highway_filter)) {
    check_highway_filter(highway_filter)
  }

  # Extract the dots arguments as alist
  all.args <- list(...)

  # Identifying the names of the parameters for the dodgr function
  dodgr.pars <- names(formals(dodgr::weight_streetnet))
  dodgr.pars <- dodgr.pars[!dodgr.pars %in% c("x", "id_col")]

  # Get a subset of the all.args that are not in dodgr.pars
  current.args <- all.args[!names(all.args) %in% c(dodgr.pars)]

  # Compile the arguments for the oe_get_tidynetwork function, including the highway_filter
  tidynet.args <- list(highway_filter = highway_filter)
  tidynet.args <- c(current.args, tidynet.args)

  # Calling the oe_get_tidynetwork function with the filtered arguments
  net <- do.call(oe_get_tidynetwork, tidynet.args)

  # Calling the dodgr::weight_streetnet function with the net and the remaining arguments
  dodgr_args <- list(x = net)
  dodgr_args <- c(dodgr_args, all.args[names(all.args) %in% dodgr.pars])

  # Returning the weighted_streetnetwork
  do.call(dodgr::weight_streetnet, dodgr_args)
}


## Utils

# This function simplifies the highway values by removing the "_link" suffix and filtering by `highway_filter` if specified.

tidy_highway <- function(net, highway_filter) {
    net$highway <- gsub(
      pattern = "_link",
      replacement = "",
      x = net$highway
    )

    if (!is.null(highway_filter)) {
      net <- net[net$highway %in% highway_filter, ]
    }
    net
}

#' Tidy the oneway values in a osm network
#'
#' This helper function standardises the oneway values in a osm network.
#' It also applies the implied `oneway` tag restriction based on the `junction`
#' tag values if specified.
#'
#' @param net_raw a `sf` object representing a spatial network with the `oneway` and `junction` columns
#' @param implied_oneway logical, whether to apply the implied `oneway` restriction
#'
#' @returns a `sf` object with standardised oneway values
#'
#' @details For more information on the implied oneway restriction, see [wiki.openstreetmap.org](https://wiki.openstreetmap.org/wiki/Key:oneway#Implied_oneway_restriction).
#'
#'
#' @examples
#' \dontrun{
#' sf_net <- osmextract::oe_get_network(place = "ITS Leeds", mode = "driving")
#' sf_net_tidy <- tidy_oneway(sf_net, implied_oneway = TRUE)
#' }
tidy_oneway <- function(
    net_raw,
    implied_oneway = TRUE
) {
  if (!is.logical(implied_oneway)) {
    stop(
      "The implied_oneway parameter must be a logical value (TRUE or FALSE)."
    )
  }

  # Simplifying the bi-directional tags
  net_raw$oneway[
    is.na(net_raw$oneway) | net_raw$oneway %in% c("alternating", "reversible")
  ] <- "no"

  # Reversing the geometries with -1
  sf::st_geometry(net_raw[
    net_raw$oneway == "-1",
  ]) <- sf::st_reverse(sf::st_geometry(net_raw[net_raw$oneway == "-1", ]))

  net_raw$oneway[net_raw$oneway == "-1"] <- "yes"

  if ("junction" %in% names(net_raw) && implied_oneway) {
    message("The implied oneway restriction is applied.")

    net_raw$oneway[
      net_raw$junction %in% c("roundabout", "motorway") & net_raw$oneway == "no"
    ] <- "yes"
  } else {
    message(
      "The junction column is not present in the network. The implied oneway restriction is not applied."
    )
  }

  net_raw
}

# Function for summarise attributes of edges when converting to sfnetwork
collapse_function <- function(x) {
  paste(unique(x), collapse = ",")
}

# function to ensure that the string values match the possible values for the highway_filter parameter
check_highway_filter <- function(highway_filter) {
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

