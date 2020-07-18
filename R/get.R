#' Download, translate and read OSM extracts
#'
#' @param place Description of the geographical area that should be download
#'   through the chosen `provider`. Can be either a length-1 character vector, a
#'   length-1 `sfc_POINT` object or a numeric vector with length 2. See details
#'   and examples.
#' @param layer Which `layer` should be read in? Typically `points`, `lines`
#' (the default), `multilinestrings`, `multipolygons` or `other_relations`.
#' @param provider Which provider should be used to download the data?
#'   Available providers can be found with the following command:
#'   `osmextractr:::oe_available_providers()`
#' @param match_by Which column of the provider data should be used for matching
#'   the input place with the provider's data? The default is "name". Check
#'   details and examples to understand how this parameter works. Ignored if
#'   `place` is not a character vector since the matching is performed through a
#'   spatial operation.
#' @param max_string_dist Numeric value greater or equal than 0. What is the
#'   maximum distance in fuzzy matching to tolerate before asking the user to
#'   select which zone to download? This parameter is set equal to 0 if
#'   `match_by` is equal to `iso3166_1_alpha2` or `iso3166_2`. Check details and
#'   examples to understand why this parameter is important. Ignored if `place`
#'   is not a character vector since the matching is performed through a spatial
#'   operation.
#' @param interactive_ask Boolean. If `TRUE` the function creates and
#'   interactive menu in case the best match is further than `max_string_dist`.
#'   Check details and examples to understand why this parameter is important.
#'   Ignored if `place` is not a character vector since the matching is
#'   performed through a spatial operation.
#' @param download_directory Where to download the file containing the OSM data?
#' By default this is `tempdir()`, which changes each time you restart R.
#' You can set a persistent `download_directory` by adding the following
#' to your `.Renviron` file (e.g. with `usethis::edit_r_environ()`):
#' `OSMEXT_DOWNLOAD_DIRECTORY=/path/to/osm/data`.
#' @param force_download Should the file be updated if it has already been
#' downloaded? `FALSE` by default.
#' @param max_file_size The maximum file size to download without asking in
#'   interactive mode. Default: `5e+8`, half a gigabyte.
#' @param vectortranslate_options Options to pass to the [`sf::gdal_utils()`]
#' argument `options`. Set by default. Check details and examples.
#' @param osmconf_ini The configuration file specifying which columns should be
#' in the resulting data frame. See documentation at
#' [gdal.org](https://gdal.org/drivers/vector/osm.html) for details.
#' @param extra_attributes Which addition columns, corresponding to OSM keys,
#' should be in the resulting dataset? `NULL` by default.
#' @param force_vectortranslate Force the original `.pbf` file to be translated
#' into a `.gpkg` file, even if a `.gpkg` associated with the `provider` zone
#' already exists.
#' @param skip_vectortranslate Boolean. If `TRUE` then the function skips all
#'   the vectortranslate operations and it reads (or simply returns the path) of
#'   the .osm.pbf file. `FALSE` by default.
#' @param oe_verbose Boolean. If `TRUE` the function prints informative messages.
#' @param oe_quiet Should files be downloaded without a progress bar?
#' `FALSE` by default.
#' @param download_only Boolean. If `TRUE` then the function only returns the
#'   path where the matched file is stored, instead of reading it. `FALSE` by
#'   default.
#' @param ... Arguments that should  be passed to [`sf::st_read()`]
#'
#' @return An sf object related to the input place.
#' @export
#' @details This function is a wrapper around ...
#'
#' @examples
#' its_leeds = oe_get("ITS Leeds", provider = "test", oe_verbose = TRUE)
#' class(its_leeds)
#' summary(sf::st_geometry_type(its_leeds))
#' # Add another layer to the .gpkg file
#' its_leeds_points = oe_get("ITS Leeds", provider = "test", layer = "points")
#' summary(sf::st_geometry_type(its_leeds_points))
#' # Get the .osm.pbf and .gpkg file path
#' oe_get("ITS Leeds", provider = "test", download_only = TRUE)
#' oe_get("ITS Leeds", provider = "test", download_only = TRUE, skip_vectortranslate = TRUE)
#' # add additional attributes
#' im = oe_get("ITS Leeds", provider = "test", extra_attributes = "oneway")
#' names(im)
#' \dontrun{
#' # alternative providers
#' baku = oe_get(place = "Baku", provider = "bbbike", oe_verbose = TRUE)
#' }
oe_get = function(
  place,
  layer = "lines",
  provider = "geofabrik",
  ...,
  match_by = "name",
  max_string_dist = 1,
  interactive_ask = FALSE,
  download_directory = oe_download_directory(),
  force_download = FALSE,
  max_file_size = 5e+8,
  vectortranslate_options = NULL,
  osmconf_ini = NULL,
  extra_attributes = NULL,
  force_vectortranslate = NULL,
  download_only = FALSE,
  skip_vectortranslate = FALSE,
  oe_verbose = FALSE,
  oe_quiet = FALSE
) {
  # Match the input place with the provider's data.
  matched_zone = oe_match(
    place = place,
    provider = provider,
    match_by = match_by,
    max_string_dist = max_string_dist,
    interactive_ask = interactive_ask,
    oe_verbose = oe_verbose
  )

  if(!is.null(extra_attributes) && is.null(force_vectortranslate)) {
    force_vectortranslate = TRUE
  }

  # Extract the matched URL and file size and pass these parameters to the
  # osmext-download function.
  file_url = matched_zone[["url"]]
  file_size = matched_zone[["file_size"]]
  file_path = oe_download(
    file_url = file_url,
    download_directory = download_directory,
    provider = provider,
    file_size = file_size,
    force_download = force_download,
    max_file_size = max_file_size,
    oe_verbose = oe_verbose
  )

  # Check for skip_vectortranslate since, in that case, we don't need the
  # vectortranslate process
  if (isTRUE(skip_vectortranslate) && isTRUE(download_only)) {
    return(file_path)
  }
  if (isTRUE(skip_vectortranslate)) {
    return(sf::st_read(file_path, layer = layer, ...))
  }

  # Pass the file_path to oe_vectortranslate
  gpkg_file_path = oe_vectortranslate(
    file_path = file_path,
    vectortranslate_options = vectortranslate_options,
    layer = layer,
    osmconf_ini = osmconf_ini,
    extra_attributes = extra_attributes,
    force_vectortranslate = force_vectortranslate,
    oe_verbose = oe_verbose
  )

  # Should we read the file or simply return its path?
  if (isTRUE(download_only)) {
    return(gpkg_file_path)
  }

  # Check if the layer is not present in the gpkg file
  if (layer %!in% sf::st_layers(gpkg_file_path)[["name"]]) {
    if (layer %!in% sf::st_layers(file_path)[["name"]]) {
      stop(
        "You selected the layer ", layer,
        ", which is not present in the .gpkg file or the .pbf file"
      )
    }
    # Try to add the new layer from the .osm.pbf file to the .gpkg file
    if (isTRUE(oe_verbose)) {
      message("Adding a new layer to the .gpkg file")
    }

    gpkg_file_path = oe_vectortranslate(
      file_path = file_path,
      vectortranslate_options = vectortranslate_options,
      layer = layer,
      osmconf_ini = osmconf_ini,
      extra_attributes = extra_attributes,
      force_vectortranslate = TRUE,
      oe_verbose = oe_verbose
    )
  }

  # Read the translated file with sf::st_read
  sf::st_read(
    dsn = gpkg_file_path,
    layer = layer,
    ...
  )

}

