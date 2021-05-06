#' Translate a .osm.pbf file into .gpkg format
#'
#' This function is used to translate a `.osm.pbf` file into `.gpkg` format.
#' The conversion is performed using
#' [ogr2ogr](https://gdal.org/programs/ogr2ogr.html#ogr2ogr) through
#' `vectortranslate` utility in [sf::gdal_utils()] . It was created following
#' [the
#' suggestions](https://github.com/OSGeo/gdal/issues/2100#issuecomment-565707053)
#' of the maintainers of GDAL. See Details and examples to understand the basic
#' usage, and check the introductory vignette for more complex use-cases.
#'
#' @details The new `.gpkg` file is created in the same directory as the input
#'   `.osm.pbf` file. The translation process is performed using the
#'   `vectortranslate` utility in [sf::gdal_utils()]. This operation can be
#'   customized in several ways modifying the parameters `layer`,
#'   `extra_tags`, `osmconf_ini`, and `vectortranslate_options`.
#'
#'   The `.osm.pbf` files processed by GDAL are usually categorized into 5
#'   layers, named `points`, `lines`, `multilinestrings`, `multipolygons` and
#'   `other_relations`. Check the first paragraphs
#'   [here](https://gdal.org/drivers/vector/osm.html) for more details. This
#'   function can covert only one layer at a time, and the parameter `layer` is
#'   used to specify which layer of the `.osm.pbf` file should be converted.
#'   Several layers with different names can be stored in the same `.gpkg` file.
#'   By default, the function will convert the `lines` layer (which is the most
#'   common one according to our experience).
#'
#'   The arguments `osmconf_ini` and `extra_tags` are used to modify how
#'   GDAL reads and processes a `.osm.pbf` file. More precisely, several operations
#'   that GDAL performs on the input `.osm.pbf` file are governed by a `CONFIG`
#'   file, that you can check at the following
#'   [link](https://github.com/OSGeo/gdal/blob/master/gdal/data/osmconf.ini).
#'   The basic components of OSM data are called
#'   [*elements*](https://wiki.openstreetmap.org/wiki/Elements) and they are
#'   divided into *nodes*, *ways* or *relations*, so, for example, the code at
#'   line 7 of that link is used to determine which *ways* are assumed to be polygons
#'   (according to the simple-feature definition of polygon) if they are closed.
#'   Moreover, OSM data is usually described using several
#'   [*tags*](https://wiki.openstreetmap.org/wiki/Tags), i.e a pair of two
#'   items: a key and a value. The code at lines 33, 53, 85, 103, and 121 is
#'   used to determine, for each layer, which tags should be explicitly reported
#'   as fields (while all the other tags are stored in the `other_tags` column,
#'   see [oe_get_keys()]). The parameter `extra_tags` is used to determine
#'   which extra tags (i.e. key/value pairs) should be added to the `.gpkg`
#'   file.
#'
#'   By default, the vectortranslate operations are skipped if the
#'   function detects a file having the same path as the input file, `.gpkg`
#'   extension and a layer with the same name as the parameter `layer` with all
#'   `extra_tags`. In that case the function will simply return the path
#'   of the `.gpkg` file. This behaviour can be overwritten by setting
#'   `force_vectortranslate = TRUE`. The parameter `osmconf_ini` is used to pass
#'   your own `CONFIG` file in case you need more control over the GDAL
#'   operations. In that case the vectortranslate operations are never skipped.
#'   Check the package introductory vignette for an example. If `osmconf_ini` is
#'   equal to `NULL` (the default), then the function uses default `osmconf.ini`
#'   file defined by GDAL (but for the extra tags).
#'
#'   The parameter `vectortranslate_options` is used to control the arguments
#'   that are passed to `ogr2ogr` via [sf::gdal_utils()] when converting between
#'   `.pbf` and `.gpkg` formats. `ogr2ogr` can perform various operations during
#'   the conversion process, such as spatial filters or SQL queries. These
#'   operations are determined by the `vectortranslate_options` argument. If
#'   `NULL` (default value), then `vectortranslate_options` is set equal to
#'
#'   `c("-f", "GPKG", "-overwrite", "-oo", paste0("CONFIG_FILE=", osmconf_ini),
#'   "-lco", "GEOMETRY_NAME=geometry", layer)`.
#'
#'   Explanation:
#'   * `"-f", "GPKG"` says that the output format is `GPKG`;
#'   * `"-overwrite` is used to delete an existing layer and recreate
#'   it empty;
#'   * `"-oo", paste0("CONFIG_FILE=", osmconf_ini)` is used to set the
#'   [Open Options](https://gdal.org/drivers/vector/osm.html#open-options)
#'   for the `.osm.pbf` file and change the `CONFIG` file (in case the user
#'   asks for any extra tag or a totally different CONFIG file);
#'   * `"-lco", "GEOMETRY_NAME=geometry"` is used to change the
#'   [layer creation options](https://gdal.org/drivers/vector/gpkg.html?highlight=gpkg#layer-creation-options)
#'   for the `.gpkg` file and modify the name of the geometry column;
#'   * `layer` indicates which layer should be converted.
#'
#'   Check the introductory vignette, the help page of [`sf::gdal_utils()`] and
#'   [here](https://gdal.org/programs/ogr2ogr.html) for an extensive
#'   documentation on all available options.
#'
#' @inheritParams oe_get
#' @param file_path Character string representing the path of the input
#'   `.pbf` or `.osm.pbf` file.
#'
#' @return Character string representing the path of the `.gpkg` file.
#' @export
#'
#' @seealso [oe_get_keys()]
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
#'
#' # Check that the file was downloaded
#' list.files(tempdir(), pattern = "pbf|gpkg", full.names = TRUE)
#'
#' # Convert to gpkg format
#' its_gpkg = oe_vectortranslate(its_pbf)
#'
#' # Now there is an extra .gpkg file
#' list.files(tempdir(), pattern = "pbf|gpkg", full.names = TRUE)
#'
#' # Check the layers of the .gpkg file
#' sf::st_layers(its_gpkg, do_count = TRUE)
#'
#' # Add points layer
#' its_gpkg = oe_vectortranslate(its_pbf, layer = "points")
#' sf::st_layers(its_gpkg, do_count = TRUE)
#'
#' # Add extra tags to the lines layer
#' names(sf::st_read(its_gpkg, layer = "lines", quiet = TRUE))
#' its_gpkg = oe_vectortranslate(
#'   its_pbf,
#'   extra_tags = c("oneway", "maxspeed")
#' )
#' names(sf::st_read(its_gpkg, layer = "lines", quiet = TRUE))
#'
#' # Remove .pbf and .gpkg files in tempdir
#' # (since they may interact with other examples)
#' file.remove(list.files(path = tempdir(), pattern = "(pbf|gpkg)", full.names = TRUE))
oe_vectortranslate = function(
  file_path,
  layer = "lines",
  vectortranslate_options = NULL,
  osmconf_ini = NULL,
  extra_tags = NULL,
  force_vectortranslate = FALSE,
  never_skip_vectortranslate = FALSE,
  quiet = FALSE
) {
  # Check that the input file was specified using the format
  # ".../something.pbf". This is important for creating the .gpkg file path.
  if (tools::file_ext(file_path) != "pbf" || !file.exists(file_path)) {
    stop("The parameter file_path must correspond to an existing .pbf file")
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

  # Check if the user passed its own osmconf.ini file or vectortranslate_options
  # since, in that case, we always need to perform the vectortranslate
  # operations (since it's too difficult to determine if an existing .gpkg file
  # was generated following a particular .ini file with some options)
  if (!is.null(osmconf_ini) || !is.null(vectortranslate_options)) {
    force_vectortranslate = TRUE
    never_skip_vectortranslate = TRUE
  }

  # Check if an existing .gpkg file contains the selected layer
  if (file.exists(gpkg_file_path) && isFALSE(force_vectortranslate)) {
    if (layer %!in% sf::st_layers(gpkg_file_path)[["name"]]) {
      # Try to add the new layer from the .osm.pbf file to the .gpkg file
      if (isFALSE(quiet)) {
        message("Adding a new layer to the .gpkg file")
      }

      force_vectortranslate = TRUE
    }
  }

  # Check if the user choose to add some extra tags
  if (!is.null(extra_tags)) {
    force_vectortranslate = TRUE
    # Check if all extra keys are already present into an existing .gpkg file I
    # set is.null(osmconf_ini) since if the user pass its own osmconf.ini file
    # then the vectortranslate operations must be performed in any case
    if (
      file.exists(gpkg_file_path) &&
      is.null(osmconf_ini) &&
      # The next condition is used to check that the function is not looking for
      # old tags in a non-existing layer, otherwise the following code will fail
      # with an error:
      # its_gpkg = oe_vectortranslate(its_pbf)
      # oe_vectortranslate(
      #   its_pbf,
      #   layer = "points",
      #   extra_tags = "oneway"
      # )
      layer %in% sf::st_layers(gpkg_file_path)[["name"]] &&
      !never_skip_vectortranslate
    ) {
      old_tags = names(sf::st_read(
        gpkg_file_path,
        layer = layer,
        quiet = TRUE,
        query = paste0("select * from \"", layer, "\" limit 0")
      ))
      if (all(extra_tags %in% old_tags)) {
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

  # The extra_tags argument is ignored if the user set its own osmconf_ini file
  # (since we do not know how it was generated):
  # See https://github.com/ropensci/osmextract/issues/117
  if (!is.null(osmconf_ini) && !is.null(extra_tags)) {
    warning(
      "The argument extra_tags is ignored when osmconf_ini is not NULL.",
      call. = FALSE,
      immediate. = TRUE
    )
    extra_tags = NULL
  }

  # First we need to set the values for the parameter osmconf_ini (if it is set
  # to NULL, i.e. the default).
  if (is.null(osmconf_ini)) {
    # The file osmconf.ini stored in the package is the default osmconf.ini used
    # by GDAL at stored at the following link:
    # https://github.com/OSGeo/gdal/blob/master/gdal/data/osmconf.ini
    # It was saved on the 9th of July 2020.
    osmconf_ini = system.file("osmconf.ini", package = "osmextract")
  }

  # Add the extra tags to the default osmconf.ini. If the user set its own
  # osmconf.ini file we need to skip this step.
  if (
    !is.null(extra_tags) &&
    # The following condition checks whether the user set its own CONFIG file
    osmconf_ini == system.file("osmconf.ini", package = "osmextract")
  ) {
    temp_ini = readLines(osmconf_ini)
    id_old = grep(
      paste0(
        "attributes=", paste(get_ini_layer_defaults(layer), collapse = ",")
      ),
      temp_ini
    )
    temp_ini[[id_old]] = paste(
      c(temp_ini[[id_old]], extra_tags),
      collapse = ","
    )
    temp_ini_file = tempfile(fileext = ".ini")
    writeLines(temp_ini, con = temp_ini_file)
    osmconf_ini = temp_ini_file
  }

  # If vectortranslate options is NULL (the default value), then we adopt the
  # following set of (basic) options:
  if (is.null(vectortranslate_options)) {
    vectortranslate_options = c(
      "-f", "GPKG", #output file format
      "-overwrite", # overwrite an existing file
      "-oo", paste0("CONFIG_FILE=", osmconf_ini), # open options
      "-lco", "GEOMETRY_NAME=geometry" # layer creation options
    )

    vectortranslate_options = c(vectortranslate_options, layer)
  }

  # Otherwise we check the input options and append the "basic" options:
  if (!is.null(vectortranslate_options)) {
    # Check if the user omitted the "-f" option (which is used to select the
    # format_name)
    if ("-f" %!in% vectortranslate_options) {
      vectortranslate_options = c(vectortranslate_options, "-f", "GPKG")
    }

    # TODO: Check that the value after -f is always equal to GPKG.

    #  Check if the user omitted the "-overwrite" option
    if ("-overwrite" %!in% vectortranslate_options) {
      vectortranslate_options = c(vectortranslate_options, "-overwrite")
    }

    # TODO: Check that the user omitted "-append" and "-update" options

    # Check if the user set any open option
    if ("-oo" %!in% vectortranslate_options) {
      vectortranslate_options = c(vectortranslate_options, "-oo", paste0("CONFIG_FILE=", osmconf_ini))
    }

    # Check if the user set any layer creation option (lco)
    if ("-lco" %!in% vectortranslate_options) {
      vectortranslate_options = c(vectortranslate_options, "-lco", "GEOMETRY_NAME=geometry")
    }

    # Add the layer
    vectortranslate_options = c(vectortranslate_options, layer)
  }

  if (isFALSE(quiet)) {
    message(
      "Start with the vectortranslate operations on the input file!"
    )
  }

  # Now we can apply the vectortranslate operation from gdal_utils: See
  # https://github.com/ropensci/osmextract/issues/150 for a discussion on
  # normalizePath
  sf::gdal_utils(
    util = "vectortranslate",
    source = normalizePath(file_path),
    destination = normalizePath(gpkg_file_path, mustWork = FALSE),
    options = vectortranslate_options,
    quiet = quiet
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
#' This function returns the names of all keys that are stored in `other_tags`
#' column. See Details.
#'
#' @details OSM data are typically documented using several
#'   [`tags`](https://wiki.openstreetmap.org/wiki/Tags), i.e. pairs of two
#'   items, namely a `key` and a `value`. As documented in
#'   [`oe_vectortranslate()`], the conversion between `.osm.pbf` and `.gpkg`
#'   formats is governed by a `CONFIG` file that lists which tags must be
#'   explicitly added to the `.gpkg` file, while all the other keys are
#'   automatically stored using an `other_tags` field with a syntax compatible
#'   with the PostgreSQL HSTORE type. This function can be used to display the
#'   names of all keys stored in the `other_tags` field.
#'
#'   The `hstore_get_value()` function can be used inside the `query` argument
#'   to extract one particular tag from an existing file. Check the introductory
#'   vignette and see examples.
#'
#'   The definition of a generic S3 implementation started in
#'   [osmextract/issues/138](https://github.com/ropensci/osmextract/issues/138).
#'
#' @seealso `oe_vectortranslate()` and
#'   [osmextract/issues/107](https://github.com/ropensci/osmextract/issues/107).
#'
#' @inheritParams oe_get
#' @param zone An `sf` object with an `other_tags` field, or a character vector
#'   (of length 1) that points to a `.osm.pbf` or `.gpkg` file with an
#'   `other_tags` field.
#'
#' @return A character vector indicating the name of all keys stored in
#'   "other_tags" field.
#' @export
#'
#' @examples
#' # Get keys from pbf file
#' itsleeds_pbf_path = oe_download(
#'   oe_match("ITS Leeds")$url,
#'   download_directory = tempdir(),
#'   provider = "test"
#' )
#' oe_get_keys(itsleeds_pbf_path)
#' itsleeds_gpkg_path = oe_get(
#'   "ITS Leeds",
#'   download_only = TRUE,
#'   download_directory = tempdir(),
#'   quiet = TRUE
#' )
#' itsleeds_gpkg_path
#' oe_get_keys(itsleeds_gpkg_path)
#'
#' itsleeds = oe_get("ITS Leeds", quiet = TRUE, download_directory = tempdir())
#' oe_get_keys(itsleeds)
#'
#' # Add an extra key to an existing .gpkg file without vectortranslate
#' names(oe_read(
#'   itsleeds_gpkg_path,
#'   query = "SELECT *,  hstore_get_value(other_tags, 'oneway')  AS oneway FROM lines"
#' ))
#'
#' # Remove .pbf and .gpkg files in tempdir
#' # (since they may interact with other examples)
#' file.remove(list.files(path = tempdir(), pattern = "(pbf|gpkg)", full.names = TRUE))
  oe_get_keys = function(zone, layer = "lines") {
  UseMethod("oe_get_keys")
}

#' @name oe_get_keys
#' @export
oe_get_keys.default = function(zone, layer = "lines") {
  stop(
    "At the moment there is no support for objects of class ",
    class(zone)[1], ".",
    " Feel free to open a new issue at github.com/ropensci/osmextract",
    call. = FALSE
  )
}

#' @name oe_get_keys
#' @export
oe_get_keys.character = function(zone, layer = "lines") {
  if (length(zone) != 1L) {
    stop("The input file must have length 1", call. = FALSE)
  }

  if (!file.exists(zone)) {
    stop(
      "The input file does not exist.",
      "You can download it using oe_get(zone, download_only = TRUE).",
      call. = FALSE
    )
  }

  # We don't need the following if clause, since actually we can read also from
  # .pbf files. See also https://github.com/ropensci/osmextract/discussions/188.
  # if (tools::file_ext(zone) != "gpkg") {
  #   stop("The input file must have a .gpkg extension.", call. = FALSE)
  # }

  # Check that the input file contains the other_tags field
  # See also https://github.com/ropensci/osmextract/issues/158
  existing_fields = colnames(
    sf::st_read(
      dsn = zone,
      layer = layer,
      query = paste0("SELECT * FROM ", layer, " LIMIT 0"),
      quiet = TRUE
    )
  )

  if ("other_tags" %!in% existing_fields) {
    stop("The input file must have an other_tags field.", call. = FALSE)
  }

  # Read the gpkg file selecting only the other_tags column.
  # The query is different between .pbf and .gpkg objects. See also
  # https://github.com/ropensci/osmextract/discussions/188
  if (tools::file_ext(zone) == "pbf") {
    query_for_other_tags = paste0("select other_tags from ", layer)
  } else if (tools::file_ext(zone) == "gpkg") {
    query_for_other_tags = paste0("select other_tags, geometry from ", layer)
  } else {
    stop("The input file must have .pbf or .gpkg extension", call. = FALSE)
  }

  other_tags = sf::st_read(
    dsn = zone,
    layer = layer,
    query = query_for_other_tags,
    quiet = TRUE
  )

  get_keys(other_tags)
}

#' @name oe_get_keys
#' @export
oe_get_keys.sf = function(zone, layer = "lines") {
  if ("other_tags" %!in% names(zone)) {
    stop("The input object must have an other_tags field.", call. = FALSE)
  }

  get_keys(zone)
}


# The following is an internal function used to extract the new keys from an
# "other_tags" field
get_keys = function(x) {
  # Create regex
  osm_matches = gregexpr(pattern = '[^\"=>,\\]+', x[["other_tags"]])
  key_value_matches = regmatches(x[["other_tags"]], osm_matches)

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


