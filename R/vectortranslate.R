#' Translate a `.osm.pbf` file into `.gpkg` format
#'
#' This function is used to translate a `.osm.pbf` file into `.gpkg` format.
#' The conversion is performed using
#' [ogr2ogr](https://gdal.org/programs/ogr2ogr.html#ogr2ogr) through
#' `vectortranslate` utility in `sf::gdal_utils()`. It was created following
#' [the
#' suggestions](https://github.com/OSGeo/gdal/issues/2100#issuecomment-565707053)
#' of the maintainers of GDAL. See Details and Examples to understand the basic
#' usage, and check the introductory vignette for more complex use-cases.
#'
#' @details The new `.gpkg` file is created in the same directory as the input
#'   `.osm.pbf` file. The translation process is performed using the
#'   `vectortranslate` utility in `sf::gdal_utils()`. This operation can be
#'   customized in several ways modifying the parameters `layer`,
#'   `extra_attributes`, `osmconf_ini`, and `vectortranslate_options`.
#'
#'   The `.osm.pbf` files processed using GDAL are usually categorized into 5
#'   layers, named `points`, `lines`, `multilinestrings`, `multipolygons` and
#'   `other_relations`. Check the first paragraphs
#'   [here](https://gdal.org/drivers/vector/osm.html) for more details. This
#'   function can covert only one later at a time, and the parameter `layer` is
#'   used to specify which layer of the `.osm.pbf` file should be converted into
#'   the `.gpkg` file. Several layers with different names can be stored in the
#'   same `.gpkg` file. By default, the function will convert the `lines` layer
#'   (which is the most common one according to our experience).
#'
#'   The arguments `osmconf_ini` and `extra_attributes` are used to modify how
#'   GDAL read and process a `.osm.pbf` file. More precisely, several operations
#'   that GDAL performs on the input `.osm.pbf` file are governed by a `CONFIG`
#'   file, that you can check at the following
#'   [link](https://github.com/OSGeo/gdal/blob/master/gdal/data/osmconf.ini).
#'   The basic components of OSM data are called
#'   [*elements*](https://wiki.openstreetmap.org/wiki/Elements) and they are
#'   divided into *nodes*, *ways* or *relations*, so, for example, the code at
#'   line 7 is used to determine which *ways* are assumed to be polygons if they
#'   are closed. Moreover, OSM data is usually described using several
#'   [*tags*](https://wiki.openstreetmap.org/wiki/Tags), i.e a pair of two
#'   items: a key and a value. The code at lines 33, 53, 85, 103, and 121 is
#'   used to determine, for each layer, which tags should be explicitly reported
#'   as fields (while all the other tags are stored in the `other_tags` column,
#'   see `oe_get_keys()`). The parameter `extra_attributes` is used to determine
#'   which extra tags (i.e. key/value pairs) should be added to the `.gpkg`
#'   file. By default, the vectortranslate operations are skipped if the
#'   function detects a file having the same path as the input file, `.gpkg`
#'   extension and a layer with the same name as the parameter `layer` with all
#'   `extra_attributes`. In that case the function will simply return the path
#'   of the `.gpkg` file. This behaviour can be overwritten by setting
#'   `force_vectortranslate = TRUE`. The parameter `osmconf_ini` is used to pass
#'   your own `CONFIG` file in case you need more control over the GDAL
#'   operations. In that case the vectortranslate operations are never skipped.
#'   Check the package introductory vignette for an example. If `osmconf_ini` is
#'   equal to `NULL` (the default), then the function uses default `osmconf.ini`
#'   file defined by GDAL (but for the extra attributes).
#'
#'   The parameter `vectortranslate_options` is used to control the arguments
#'   that are passed to `ogr2ogr` via `sf::gdal_utils()` when converting between
#'   `.pbf` and `.gpkg` formats. `ogr2ogr` can perform various operations during
#'   the conversion process, such as spatial filters or SQL queries. These
#'   operations are determined by the `vectortranslate_options` argument. If
#'   `NULL` (default value), then `vectortranslate_options` is set equal to
#'   `c("-f", "GPKG", "-overwrite", "-oo", paste0("CONFIG_FILE=", osmconf_ini),
#'   "-lco", "GEOMETRY_NAME=geometry", layer)`. Explanation:
#'   * `"-f", "GPKG"` says that the output format is `GPKG`;
#'   * `"-overwrite` is used to delete an existing layer and recreate
#'   it empty;
#'   * `"-oo", paste0("CONFIG_FILE=", osmconf_ini)` is used to set the
#'   [Open Options](https://gdal.org/drivers/vector/osm.html#open-options)
#'   for the `.osm.pbf` file and change the `CONFIG` file (in case the user
#'   asks for any extra attribute or a totally different CONFIG file);
#'   * `"-lco", "GEOMETRY_NAME=geometry"` is used to change the
#'   [layer creation options](https://gdal.org/drivers/vector/gpkg.html?highlight=gpkg#layer-creation-options)
#'   for the `.gpkg` file and modify the name of the geometry column;
#'   * `layer` indicates which layer should be converted.
#'
#'   Check the introductory vignette, the help page of `sf::gdal_utils()` and
#'   [here](https://gdal.org/programs/ogr2ogr.html) for an extensive
#'   documentation on all available options.
#'
#' @inheritParams oe_get
#' @param file_path Character string representing the path of the input
#'   `.osm.pbf` file.
#'
#' @return Character string representing the path of the `.gpkg` file.
#' @export
#'
#' @seealso `oe_get_keys()`
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
#' # Check that the file was downloaded
#' list.files(tempdir(), pattern = "pbf|gpkg")
#' # Convert to gpkg format
#' its_gpkg = oe_vectortranslate(its_pbf)
#' list.files(tempdir(), pattern = "pbf|gpkg")
#'
#' # Check the layers of the .gpkg file
#' sf::st_layers(its_gpkg, do_count = TRUE)
#' # Add points layer
#' its_gpkg = oe_vectortranslate(its_pbf, layer = "points")
#' sf::st_layers(its_gpkg, do_count = TRUE)
#'
#' # Add extra attributes to the lines layer
#' names(sf::st_read(its_gpkg, layer = "lines", quiet = TRUE))
#' its_gpkg = oe_vectortranslate(
#'   its_pbf,
#'   extra_attributes = c("oneway", "maxspeed")
#'  )
#' names(sf::st_read(its_gpkg, layer = "lines", quiet = TRUE))
#' # Check the introductory vignette for more complex examples.
oe_vectortranslate = function(
  file_path,
  layer = "lines",
  vectortranslate_options = NULL,
  osmconf_ini = NULL,
  extra_attributes = NULL,
  force_vectortranslate = FALSE,
  quiet = TRUE
) {
  # Check that the input file was specified using the format
  # ".../something.pbf". This is important for creating the .gpkg file path.
  if (tools::file_ext(file_path) != "pbf") {
    stop("The parameter file_path must correspond to a .pbf file")
  }

  # Check that the layer param is not NA or NULL
  if (
    is.null(layer) ||
    is.na(layer) ||
    # I need the following condition to check that the function
    # get_ini_layer_defaults does not return NULL
    layer %!in% c(
      "points", "lines", "multipolygons", "multilinestrings", "other_relations"
    )
  ) {
    stop(
      "You need to specify the layer parameter and it must be one of",
      " points, lines, multipolygons, multilinestrings or other_relations."
    )
  }

  # We need to build the file path of the .gpkg using the following convention:
  # it is the same file path of the .pbf/.osm.pbf file but with .gpkg extension.
  # I need to use the if clause to check if the input file is something.osm.pbf
  # or something.pbf
  if (tools::file_ext(tools::file_path_sans_ext(file_path)) == "osm") {
    gpkg_file_path = paste0(
      # I need the double file_path_san_ext to cancel the .osm and the .pbf
      tools::file_path_sans_ext(tools::file_path_sans_ext(file_path)),
      ".gpkg"
    )
  } else {
    # Just change the extensions
    gpkg_file_path = paste0(tools::file_path_sans_ext(file_path), ".gpkg")
  }

  # Check if the user passed its own osmconf.ini file since, in that case, we
  # always need to perform the vectortranslate operations (since it's too
  # difficult to determine if an existing .gpkg file was generated following a
  # particular .ini file)
  if (!is.null(osmconf_ini)) {
    force_vectortranslate = TRUE
  }

  # Check if an existing .gpkg file contains the selected layer
  if (file.exists(gpkg_file_path)) {
    if (layer %!in% sf::st_layers(gpkg_file_path)[["name"]]) {
      # Try to add the new layer from the .osm.pbf file to the .gpkg file
      if (isFALSE(quiet)) {
        message("Adding a new layer to the .gpkg file")
      }

      force_vectortranslate = TRUE
    }
  }

  # Check if the user choose to add some extra attribute / key
  if (!is.null(extra_attributes)) {
    force_vectortranslate = TRUE
    # Check if all extra keys are already present into an existing .gpkg file I
    # set is.null(osmconf_ini) since if the user pass its own osmconf.ini file
    # then the vectortranslate operations must be performed in any case
    if (
      file.exists(gpkg_file_path) &&
      is.null(osmconf_ini) &&
      # The next test is used to check that the function is not looking for old
      # attributes in a non-existing layer, otherwise the following code
      # will fail with an error:
      # its_gpkg = oe_vectortranslate(its_pbf)
      # oe_vectortranslate(
      #   its_pbf,
      #   layer = "points",
      #   extra_attributes = "oneway"
      # )
      layer %!in% sf::st_layers(gpkg_file_path)[["name"]]
    ) {
      old_attributes = names(sf::st_read(
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
  # raise a message and return the path of the .gpkg file.
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

  # First we need to set the values for the parameter osmconf_ini (if it is not
  # set to NULL, i.e. the default).
  if (is.null(osmconf_ini)) {
    # The file osmconf.ini stored in the package is the default osmconf.ini used
    # by GDAL at stored at the following link:
    # https://github.com/OSGeo/gdal/blob/master/gdal/data/osmconf.ini
    # It was saved on the 9th of July 2020.
    osmconf_ini = system.file("osmconf.ini", package = "osmextract")
  }

  # Add the extra attributes to the default osmconf.ini. If the user set its own
  # osmconf.ini file we need to skip this step.
  if (
    !is.null(extra_attributes) &&
    # The following condition checks whether the user set its own CONFIG file
    osmconf_ini == system.file("osmconf.ini", package = "osmextract")
  ) {
    temp_ini = readLines(osmconf_ini)
    id_old = grep(
      paste0("attributes=", paste(get_ini_layer_defaults(layer), collapse = ",")),
      temp_ini
    )
    temp_ini[[id_old]] = paste(c(temp_ini[[id_old]], extra_attributes), collapse = ",")
    temp_ini_file = paste0(tempfile(), ".ini")
    writeLines(temp_ini, con = temp_ini_file)
    osmconf_ini = temp_ini_file
  }

  # Set the vectortranslate options:
  if (is.null(vectortranslate_options)) {
    vectortranslate_options = c(
      "-f", "GPKG", #output file format
      "-overwrite", # overwrite an existing file
      "-oo", paste0("CONFIG_FILE=", osmconf_ini), # open options
      "-lco", "GEOMETRY_NAME=geometry" # layer creation options
    )

    vectortranslate_options = c(vectortranslate_options, layer)
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


#' Return all keys stored in "other_tags" column
#'
#' This function is used to return the names of all keys that are stored in
#' "other_tags" column since they were not explicitly included in the file. See
#' Details.
#'
#' @details OSM data are typically documented using several
#'   [`tags`](https://wiki.openstreetmap.org/wiki/Tags). A `tag` is a pair of
#'   two items, namely a `key` and a `value`. As we documented in
#'   `oe_vectortranslate()`, the conversion between `.osm.pbf` and `.gpkg`
#'   formats is governed by a CONFIG file that indicates which keys are
#'   explicitly added to the `.gpkg` file. All the other keys stored in the
#'   `.osm.pbf` file are automatically appended in an "other_tags" field, with a
#'   syntax compatible with the PostgreSQL HSTORE type. This function is used to
#'   display the names of all the keys stored in the "other_tags" column. See
#'   examples.
#'
#' @seealso `oe_vectortranslate()` and
#'   [#107](https://github.com/ITSLeeds/osmextract/issues/107).
#'
#' @inheritParams oe_get
#' @param file_path The path of a `.gpkg` file, typically created using
#'   `oe_vectortranslate()` or `oe_get()`.
#'
#' @return A character vector indicating the name of all keys stored in
#'   "other_tags" field.
#' @export
#'
#' @examples
#' itsleeds_gpkg = oe_get("itsleeds", provider = "test", download_only = TRUE)
#' oe_get_keys(itsleeds_gpkg)
oe_get_keys = function(
  file_path,
  layer = "lines"
) {
  if (!file.exists(file_path)) {
    stop("The input file does not exist.")
  }

  if (tools::file_ext(file_path) != "gpkg") {
    stop("The input file must have a .gpkg extension.")
  }

  # Read the gpkg file selecting only the other_tags column
  other_tags = sf::st_read(
    file_path,
    layer = layer,
    query = paste0("select other_tags, geometry from ", layer),
    quiet = TRUE
  )

  # Create regex
  osm_matches = gregexpr(pattern = '[^\"=>,\\]+', other_tags[["other_tags"]])
  key_value_matches = regmatches(other_tags[["other_tags"]], osm_matches)

  keys_per_feature = lapply(key_value_matches, function(x) {
    # character(0) occurs when other_tags is equal to NA
    if (identical(x, character(0))) {
      return(NULL)
    }
    x[seq(1, length(x), by = 2)]
  })

  unique_keys = unique(unlist(keys_per_feature))
  unique_keys
}




