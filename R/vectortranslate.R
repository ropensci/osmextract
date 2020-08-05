#' Translate a `.osm.pbf` file into `.gpkg` format
#'
#' This function is used to translate a `.osm.pbf` file into `.gpkg` format. The
#' conversion is performed using
#' [ogr2ogr](https://gdal.org/programs/ogr2ogr.html#ogr2ogr) through
#' `sf::gdal_utils()`. It was created following [the
#' suggestions](https://github.com/OSGeo/gdal/issues/2100#issuecomment-565707053)
#' of the maintainers of GDAL. See Details and Examples to understand the basic
#' functionalities, and check the introductory vignette for more complex
#' use-cases.
#'
#' @details The new `.gpkg` file is created in the same directory as the input
#'   `.osm.pbf` file. The translation process is performed using the
#'   `sf::gdal_utils()` function, setting `util = "vectortranslate"`. This
#'   operation can be customized in several ways modifying the parameters
#'   `vectortranslate_options`, `layer`, `osmconf_ini` and `extra_attributes`.
#'
#'   The `.osm.pbf` files that are read using GDAL are usually categorized into
#'   5 layers, named `points`, `lines`, `multilinestrings`, `multipolygons` and
#'   `other_relations`. Check the first paragraphs
#'   [here](https://gdal.org/drivers/vector/osm.html) for more details.  The
#'   parameter `layer` is used to specify which layer of the `.osm.pbf` file
#'   should be converted into the `.gpkg` file. Several layers with different
#'   names can be stored in the same `.gpkg` file. We can convert only one layer
#'   at time. By default, the function will convert the `lines` layer (which is
#'   the most common one according to our experience). The vectortranslate
#'   operation is skipped if the function detects a file having the same name as
#'   the input file, `.gpkg` extension and a layer with the same name as the
#'   parameter `layer`. This behaviour can be overwritten by setting
#'   `force_vectortranslate = TRUE`.
#'
#'   The arguments `osmconf_ini` and `extra_attributes` are used to modify how
#'   GDAL reads the `.osm.pbf` file. More precisely, the parameter `osmconf_ini`
#'   must be a character string specifying the path of the `.ini` file used by
#'   GDAL.
#'
#' @inheritParams oe_get
#' @param file_path Character string representing the path of the input
#'   `.osm.pbf` file
#'
#' @return Character string representing the path of the .gpkg file.
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
  layer = "lines",
  osmconf_ini = NULL,
  extra_attributes = NULL,
  force_vectortranslate = NULL,
  quiet = TRUE
) {
  # Check that the input file was specified using the format
  # ".../something.osm.pbf" format. This is important for creating the .gpkg file
  # path.
  if (
    tools::file_ext(file_path) != "pbf" ||
    tools::file_ext(tools::file_path_sans_ext(file_path)) != "osm"
    ) {
    stop(
      "The input file must be specified using the appropriate extension, i.e. ",
      "'.../something.osm.pbf'."
    )
  }

  # First we need to build the file path of the .gpkg using the following
  # convention: it is the same file path of the .osm.pbf file but with .gpkg
  # extension
  gpkg_file_path = paste0(
    # I need the double file_path_san_ext to cancel the .osm and the .pbf
    tools::file_path_sans_ext(tools::file_path_sans_ext(file_path)),
    ".gpkg"
  )

  # TODO: document this part
  if(!is.null(extra_attributes) && is.null(force_vectortranslate)) {
    force_vectortranslate = TRUE
    if (file.exists(gpkg_file_path)) {
      old_attributes <- names(sf::st_read(
        gpkg_file_path,
        layer = layer,
        quiet = TRUE,
        query = paste0("select * from \"", layer, "\" limit 0")
      ))

      if (all(extra_attributes %in% old_attributes)) {
        force_vectortranslate = FALSE
      }
    }
  }

  # If the gpgk file already exists and force_vectortranslate is FALSE then we
  # raise a message and we return the path of the .gpkg file.
  if (file.exists(gpkg_file_path) && isFALSE(force_vectortranslate)) {
    if (isFALSE(quiet)) {
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
    osmconf_ini = system.file("osmconf.ini", package = "osmextract")
  }
  if (is.null(osmconf_ini) && !is.null(extra_attributes)) {
    if (is.null(layer)) {
      stop("You need to specify the layer parameter!")
    }

    temp_ini = readLines(system.file("osmconf.ini", package = "osmextract"))
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

  if (isFALSE(quiet)) {
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

  if (isFALSE(quiet)) {
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
