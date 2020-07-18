#' Translate the .osm.pbf format into .gpkg
#'
#' @inheritParams oe_get
#' @param file_path Character string representing the full path the .osm.pbf file
#'
#' @return Character string representing the full path the .gpkg file
#' @export
#'
#' @examples
#' # First we need to match an input zone with a .osm.pbf file
#' its_match = oe_match("ITS Leeds", provider = "test")
#' # The we can download the .osm.pbf files
#' its_pbf = oe_download(
#'   file_url = its_match$url,
#'   file_size = its_match$file_size,
#'   download_directory = tempdir(),
#'   provider = "test"
#' )
#' list.files(tempdir(), pattern = "pbf|gpkg")
#' its_gpkg = oe_vectortranslate(
#'  its_pbf
#' )
#' list.files(tempdir(), pattern = "pbf|gpkg")
oe_vectortranslate = function(
  file_path,
  vectortranslate_options = NULL,
  layer = NULL,
  osmconf_ini = NULL,
  extra_attributes = NULL,
  force_vectortranslate = FALSE,
  oe_verbose = FALSE
) {
  # First we need to build the file path of the .gpkg using the following
  # convention: it is the same file path of the .osm.pbf file but with .gpkg
  # extension
  gpkg_file_path = paste0(
    # I need the double file_path_san_ext to cancel the .osm and the .pbf
    tools::file_path_sans_ext(tools::file_path_sans_ext(file_path)),
    ".gpkg"
  )

  # If the gpgk file already exists and force_vectortranslate is FALSE then we
  # raise a message and we return the path of the .gpkg file.
  if (file.exists(gpkg_file_path) && !isTRUE(force_vectortranslate)) {
    if (isTRUE(oe_verbose)) {
      message(
        "The corresponding gpkg file was already detected. ",
        "Skip vectortranslate operations."
      )
    }
    return(gpkg_file_path)
  }

  # Otherwise we are going to convert the input .osm.pbf file using the
  # vectortranslate utils from sf::gdal_util.

  # First we need to set the values for the parameters vectortranslate_options
  # and osmconf_ini (if they are set to NULL, i.e. the default).

  if (is.null(osmconf_ini) && is.null(extra_attributes)) {
    # The file osmconf.ini stored in the package is the default osmconf.ini used
    # by GDAL at stored at the following link:
    # https://github.com/OSGeo/gdal/blob/master/gdal/data/osmconf.ini
    # It was saved on the 9th of July 2020.
    osmconf_ini = system.file("osmconf.ini", package = "osmextractr")
  }
  if (is.null(osmconf_ini) && !is.null(extra_attributes)) {
    if (is.null(layer)) {
      stop("You need to specify the layer parameter!")
    }

    temp_ini = readLines(system.file("osmconf.ini", package = "osmextractr"))
    id_old = grep(
      paste0("attributes=", paste(get_ini_layer_defaults(layer), collapse = ",")),
      temp_ini
    )
    temp_ini[[id_old]] = paste(c(temp_ini[[id_old]], extra_attributes), collapse = ",")
    temp_ini_file = paste0(tempfile(), ".ini")
    writeLines(temp_ini, con = temp_ini_file)
    osmconf_ini = temp_ini_file
  }

  if (is.null(vectortranslate_options)) {
    vectortranslate_options = c(
      "-f", "GPKG",
      "-overwrite",
      "-oo", paste0("CONFIG_FILE=", osmconf_ini),
      "-lco", "GEOMETRY_NAME=geometry"
    )

    if (!is.null(layer)) {
      vectortranslate_options = c(vectortranslate_options, layer)
    }
  }

  if (isTRUE(oe_verbose)) {
    message(
      "Start with the vectortranslate operations on the input file!"
    )
  }

  # Now we can apply the vectortranslate operation from gdal_utils:
  sf::gdal_utils(
    util = "vectortranslate",
    source = file_path,
    destination = gpkg_file_path,
    options = vectortranslate_options
  )

  if (isTRUE(oe_verbose)) {
    message(
      "Finished the vectortranslate operations on the input file!"
    )
  }

  # and return the path of the gpkg file
  gpkg_file_path
}




get_ini_layer_defaults = function(layer) {
  def_layers = list(
    points = c(
      "name",
      "barrier",
      "highway",
      "ref",
      "address",
      "is_in",
      "place",
      "man_made"
    ),
    lines = c(
      "name",
      "highway",
      "waterway",
      "aerialway",
      "barrier",
      "man_made"
    ),
    multipolygons = c(
      "name",
      "type",
      "aeroway",
      "amenity",
      "admin_level",
      "barrier",
      "boundary",
      "building",
      "craft",
      "geological",
      "historic",
      "land_area",
      "landuse",
      "leisure",
      "man_made",
      "military",
      "natural",
      "office",
      "place",
      "shop",
      "sport",
      "tourism"
    ),
    multilinestrings = c("name", "type"),
    other_relations = c("name", "type")
  )
  def_layers[[layer]]
}
