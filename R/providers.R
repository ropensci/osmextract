# This is an internal function used to check that the input provider corresponds
# to one of the available providers.
oe_available_providers = function() {
  c(
    "geofabrik",
    "test",
    "bbbike",
    "openstreetmap_fr"
    # "another_provider"
  )
}

# This is an internal function that is used to load the correct provider's
# database
load_provider_data = function(provider) {
  if (
    is.numeric(provider) ||
    inherits(provider, "sfc_POINT") ||
    provider %!in% oe_available_providers()
  ) {
    oe_stop(
      .subclass = "load_provider_data-InvalidProvider",
      message = paste0(
        "You can only select one of the following providers: ",
        paste(setdiff(oe_available_providers(), "test"), collapse = " - "),
        ". Did you pass more than one place to oe_match or oe_get?"
      )
    )
  }

  provider_data = switch(
    provider,
    "geofabrik" = osmextract::geofabrik_zones,
    "test" = osmextract::test_zones,
    "bbbike" = osmextract::bbbike_zones,
    "openstreetmap_fr" = osmextract::openstreetmap_fr_zones
    # , "another" = another_provider
  )
  # See https://github.com/r-spatial/sf/issues/1419
  sf::st_crs(provider_data) = 4326
  provider_data
}

#' Summary of available providers
#'
#' This function is used to display a short summary of the major characteristics
#' of the databases associated to all available providers.
#'
#' @inheritParams oe_get
#' @return A `data.frame` with 4 columns representing the name of each available
#'   provider, the name of the corresponding database and the number of features
#'   and fields.
#' @export
#'
#' @examples
#' oe_providers()
oe_providers = function(quiet = FALSE) {
  # First I need to load the names of all available providers (except "test")
  available_providers = setdiff(oe_available_providers(), "test")

  # Then I want to calculate a few characteristics of the provider's databases:
  number_of_zones = vapply(
    available_providers,
    function(x) nrow(load_provider_data(x)),
    FUN.VALUE = integer(1)
  )
  number_of_fields = vapply(
    available_providers,
    function(x) ncol(load_provider_data(x)) - 1L,
    FUN.VALUE = integer(1)
  )

  oe_message(
    "Check the corresponding help pages to read more details about the ",
    "fields in each database (e.g. ?geofabrik_zones)",
    quiet = quiet,
    .subclass = "oe_providers_Info"
  )

  # Summary of results
  data.frame(
    available_providers = available_providers,
    database_name = paste(available_providers, "zones", sep = "_"),
    number_of_zones = number_of_zones,
    number_of_fields = number_of_fields,
    stringsAsFactors = FALSE,
    row.names = NULL
  )
}
