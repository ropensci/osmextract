#' Read a .pbf or .gpkg object
#'
#' @inheritParams oe_get
#' @param file_path The path of the .pbf file that should be translated and
#'   read-in.
#'
#' @return An sf object related to the input path.
#' @export
#'
#' @details For the moment I will consider only .osm.pbf file. The approach is more
#'   or less the same as for oe_get() but we need to skip the matching
#'   operations. In the near future I think I could merge the two approaches
#'   i.e. oe_get will be oe_match + oe_read to avoid a lot of duplication.
#'
#' @examples
#' oe_read(
#'   file_path = system.file("its-example.osm.pbf", package = "osmextract"),
#'   download_directory = tempdir()
#' )
oe_read = function(
  file_path,
  layer = "lines",
  ...,
  download_directory = oe_download_directory(),
  vectortranslate_options = NULL,
  osmconf_ini = NULL,
  extra_attributes = NULL,
  force_vectortranslate = NULL,
  skip_vectortranslate = FALSE,
  quiet = TRUE
) {

  # If the user set skip_vectortranslate = TRUE then we do not need to do
  # anything but sf::st_read.
  if (isTRUE(skip_vectortranslate)) {
    return(sf::st_read(file_path, layer = layer, quiet = quiet, ...))
  }

  # Pass the file_path to oe_vectortranslate
  gpkg_file_path = oe_vectortranslate(
    file_path = file_path,
    vectortranslate_options = vectortranslate_options,
    layer = layer,
    osmconf_ini = osmconf_ini,
    extra_attributes = extra_attributes,
    force_vectortranslate = force_vectortranslate,
    quiet = quiet
  )

  # Check if the layer is not present in the gpkg file
  if (layer %!in% sf::st_layers(gpkg_file_path)[["name"]]) {
    if (layer %!in% sf::st_layers(file_path)[["name"]]) {
      stop(
        "You selected the layer ", layer,
        ", which is not present in the .gpkg file or the .pbf file"
      )
    }
    # Try to add the new layer from the .osm.pbf file to the .gpkg file
    if (isFALSE(quiet)) {
      message("Adding a new layer to the .gpkg file")
    }

    gpkg_file_path = oe_vectortranslate(
      file_path = file_path,
      vectortranslate_options = vectortranslate_options,
      layer = layer,
      osmconf_ini = osmconf_ini,
      extra_attributes = extra_attributes,
      force_vectortranslate = TRUE,
      quiet = quiet
    )
  }

  # Read the translated file with sf::st_read
  sf::st_read(
    dsn = gpkg_file_path,
    layer = layer,
    quiet = quiet,
    ...
  )
}
