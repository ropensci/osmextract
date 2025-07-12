#' Translate a .osm.pbf file into .gpkg format
#'
#' This function is used to translate a `.osm.pbf` file into `.gpkg` format.
#' The conversion is performed using
#' [ogr2ogr](https://gdal.org/en/stable/programs/ogr2ogr.html) via the
#' `vectortranslate` utility in [sf::gdal_utils()] . It was created following
#' [the
#' suggestions](https://github.com/OSGeo/gdal/issues/2100#issuecomment-565707053)
#' of the maintainers of GDAL. See Details and Examples to understand the basic
#' usage, and check the introductory vignette for more complex use-cases.
#'
#' @details The new `.gpkg` file is created in the same directory as the input
#'   `.osm.pbf` file. The translation process is performed using the
#'   `vectortranslate` utility in [sf::gdal_utils()]. This operation can be
#'   customized in several ways modifying the parameters `layer`, `extra_tags`,
#'   `osmconf_ini`, `vectortranslate_options`, `boundary` and `boundary_type`.
#'
#'   The `.osm.pbf` files processed by GDAL are usually categorized into 5
#'   layers, named `points`, `lines`, `multilinestrings`, `multipolygons` and
#'   `other_relations`. Check the first paragraphs
#'   [here](https://gdal.org/en/stable/drivers/vector/osm.html) for more details. This
#'   function can covert only one layer at a time, and the parameter `layer` is
#'   used to specify which layer of the `.osm.pbf` file should be converted.
#'   Several layers with different names can be stored in the same `.gpkg` file.
#'   By default, the function will convert the `lines` layer (which is the most
#'   common one according to our experience).
#'
#'   The arguments `osmconf_ini` and `extra_tags` are used to modify how GDAL
#'   reads and processes a `.osm.pbf` file. More precisely, several operations
#'   that GDAL performs on the input `.osm.pbf` file are governed by a `CONFIG`
#'   file, that can be checked at the following
#'   [link](https://github.com/OSGeo/gdal/blob/master/ogr/ogrsf_frmts/osm/data/osmconf.ini).
#'   The basic components of OSM data are called
#'   [*elements*](https://wiki.openstreetmap.org/wiki/Elements) and they are
#'   divided into *nodes*, *ways* or *relations*, so, for example, the code at
#'   line 7 of that file is used to determine which *ways* are assumed to be
#'   polygons (according to the simple-feature definition of polygon) if they
#'   are closed. Moreover, OSM data is usually described using several
#'   [*tags*](https://wiki.openstreetmap.org/wiki/Tags), i.e pairs of two items:
#'   a key and a value. The code at lines 33, 53, 85, 103, and 121 is used to
#'   determine, for each layer, which tags should be explicitly reported as
#'   fields (while all the other tags are stored in the `other_tags` column).
#'   The parameter `extra_tags` is used to determine which extra tags (i.e.
#'   key/value pairs) should be added to the `.gpkg` file (other than the
#'   default ones).
#'
#'   By default, the vectortranslate operations are skipped if the function
#'   detects a file having the same path as the input file, `.gpkg` extension, a
#'   layer with the same name as the parameter `layer` and all `extra_tags`. In
#'   that case the function will simply return the path of the `.gpkg` file.
#'   This behaviour can be overwritten setting `force_vectortranslate = TRUE`.
#'   The vectortranslate operations are never skipped if `osmconf_ini`,
#'   `vectortranslate_options`, `boundary` or `boundary_type` arguments are not
#'   `NULL`.
#'
#'   The parameter `osmconf_ini` is used to pass your own `CONFIG` file in case
#'   you need more control over the GDAL operations. Check the package
#'   introductory vignette for an example. If `osmconf_ini` is equal to `NULL`
#'   (the default value), then the function uses the standard `osmconf.ini` file
#'   defined by GDAL (but for the extra tags).
#'
#'   The parameter `vectortranslate_options` is used to control the options that
#'   are passed to `ogr2ogr` via [sf::gdal_utils()] when converting between
#'   `.osm.pbf` and `.gpkg` formats. `ogr2ogr` can perform various operations
#'   during the conversion process, such as spatial filters or SQL queries.
#'   These operations can be tuned using the `vectortranslate_options` argument.
#'   If `NULL` (the default value), then `vectortranslate_options` is set equal
#'   to
#'
#'   `c("-f", "GPKG", "-overwrite", "-oo", paste0("CONFIG_FILE=", osmconf_ini),
#'   "-lco", "GEOMETRY_NAME=geometry", layer)`.
#'
#'   Explanation:
#'   * `"-f", "GPKG"` says that the output format is `GPKG`;
#'   * `"-overwrite` is used to delete an existing layer and recreate
#'   it empty;
#'   * `"-oo", paste0("CONFIG_FILE=", osmconf_ini)` is used to set the
#'   [Open Options](https://gdal.org/en/stable/drivers/vector/osm.html#open-options)
#'   for the `.osm.pbf` file and change the `CONFIG` file (in case the user
#'   asks for any extra tag or a totally different CONFIG file);
#'   * `"-lco", "GEOMETRY_NAME=geometry"` is used to change the
#'   [layer creation options](https://gdal.org/en/stable/drivers/vector/gpkg.html#layer-creation-options)
#'   for the `.gpkg` file and modify the name of the geometry column;
#'   * `layer` indicates which layer should be converted.
#'
#'   If `vectortranslate_options` is not `NULL`, then the options `c("-f",
#'   "GPKG", "-overwrite", "-oo", "CONFIG_FILE=", path-to-config-file, "-lco",
#'   "GEOMETRY_NAME=geometry", layer)` are always appended unless the user
#'   explicitly sets different default parameters for the arguments `-f`, `-oo`,
#'   `-lco`, and `layer`.
#'
#'   The arguments `boundary` and `boundary_type` can be used to set up a
#'   spatial filter during the vectortranslate operations (and speed up the
#'   process) using an `sf` or `sfc` object (`POLYGON` or `MULTIPOLYGON`). The
#'   default arguments create a rectangular spatial filter which selects all
#'   features that intersect the area. Setting `boundary_type = "clipsrc"` clips
#'   the geometries. In both cases, the appropriate options are automatically
#'   added to the `vectortranslate_options` (unless a user explicitly sets
#'   different default options). Check Examples in `oe_get()` and the
#'   introductory vignette.
#'
#'   See also the help page of [`sf::gdal_utils()`] and
#'   [ogr2ogr](https://gdal.org/en/stable/programs/ogr2ogr.html) for more examples and
#'   extensive documentation on all available options that can be tuned during
#'   the vectortranslate process.
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
#' (its_match = oe_match("ITS Leeds"))
#'
#' # Copy ITS file to tempdir so that the examples do not require internet
#' # connection. You can skip the next 3 lines (and start directly with
#' # oe_download()) when running the examples locally.
#'
#' file.copy(
#'   from = system.file("its-example.osm.pbf", package = "osmextract"),
#'   to = file.path(tempdir(), "test_its-example.osm.pbf"),
#'   overwrite = TRUE
#' )
#'
#' # The we can download the .osm.pbf file (if it was not already downloaded)
#' its_pbf = oe_download(
#'   file_url = its_match$url,
#'   file_size = its_match$file_size,
#'   download_directory = tempdir(),
#'   provider = "test"
#' )
#'
#' # Check that the file was downloaded
#' list.files(tempdir(), pattern = "pbf|gpkg")
#'
#' # Convert to gpkg format
#' its_gpkg = oe_vectortranslate(its_pbf)
#'
#' # Now there is an extra .gpkg file
#' list.files(tempdir(), pattern = "pbf|gpkg")
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
#' # Adjust vectortranslate options and convert only 10 features
#' # for the lines layer
#' oe_vectortranslate(
#'   its_pbf,
#'   vectortranslate_options = c("-limit", 10)
#' )
#' sf::st_layers(its_gpkg, do_count = TRUE)
#'
#' # Remove .pbf and .gpkg files in tempdir
#' oe_clean(tempdir())
oe_vectortranslate = function(
  file_path,
  layer = "lines",
  vectortranslate_options = NULL,
  osmconf_ini = NULL,
  extra_tags = NULL,
  force_vectortranslate = FALSE,
  never_skip_vectortranslate = FALSE,
  boundary = NULL,
  boundary_type = c("spat", "clipsrc"),
  quiet = FALSE
) {
  # Check that the input file was specified using the format
  # ".../something.pbf". This is important for creating the .gpkg file path.
  if (! tools::file_ext(file_path) %in% c("pbf", "osm") || !file.exists(file_path)) {
    oe_stop(
      .subclass = "oe_vectortranslate_filePathMissingOrNotPbf",
      message = "The parameter file_path must correspond to an existing .pbf file"
    )
  }

  # Check that the layer param is not NA or NULL
  if (
    is.null(layer) ||
    is.na(layer) ||
    # I need the following condition to check that the function
    # get_id_layer does not return NULL
    tolower(layer) %!in% c(
      "points", "lines", "multipolygons", "multilinestrings", "other_relations"
    )
  ) {
    oe_stop(
      .subclass = "oe_vectortranslate-layerNotProperlySpecified",
      message = paste0(
        "You need to specify the layer parameter and it must be one of",
        " points, lines, multipolygons, multilinestrings or other_relations."
      )
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
  # (or boundary object) since, in that case, we always need to perform the
  # vectortranslate operations (since it's too difficult to determine if an
  # existing .gpkg file was generated following a particular .ini file with some
  # options)
  if (!is.null(osmconf_ini) || !is.null(vectortranslate_options) || !is.null(boundary)) {
    force_vectortranslate = TRUE
    never_skip_vectortranslate = TRUE
  }

  # Check if an existing .gpkg file contains the selected layer
  if (file.exists(gpkg_file_path) && isFALSE(force_vectortranslate)) {
    if (layer %!in% sf::st_layers(gpkg_file_path)[["name"]]) {
      # Try to add the new layer from the .osm.pbf file to the .gpkg file
      oe_message(
        "Adding a new layer to the .gpkg file.",
        quiet = quiet,
        .subclass = "oe_vectortranslate_addingNewLayer"
      )

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
      # Starting from sf 1.0.2, sf::st_read raises a warning message when both
      # layer and query arguments are set (while it raises a warning in sf <
      # 1.0.2 when there are multiple layers and the layer argument is not set).
      # See also https://github.com/r-spatial/sf/issues/1444

      if (utils::packageVersion("sf") <= "1.0.1") {
        old_tags = names(sf::st_read(
          gpkg_file_path,
          layer = layer,
          quiet = TRUE,
          query = paste0("select * from \"", layer, "\" limit 0")
        ))
      } else {
        old_tags = names(sf::st_read(
          gpkg_file_path,
          quiet = TRUE,
          query = paste0("select * from \"", layer, "\" limit 0")
        ))
      }

      # Convert the character ":" into "_" for the extra_tags argument (see also
      # https://github.com/ropensci/osmextract/issues/260 for more details). I
      # create a temp object since I don't need to actually change the argument.

      # NB: The laundering of ":" into "_" by GDAL is actually controlled by the
      # attribute_name_laundering tag in osmconf.ini. However, since we do not
      # support the "extra_tag" and "osmconf_ini" arguments at the same time, we
      # do not need to check whether attribute_name_laundering=no is uncommented in
      # the .ini file. In fact, if osmconf_ini is not NULL, the
      # vectortranslate operations are never skipped.

      temp_extra_tags <- gsub(":", "_", extra_tags)

      if (all(temp_extra_tags %in% old_tags)) {
        force_vectortranslate = FALSE
      }
    }
  }

  # If the gpgk file already exists and force_vectortranslate is FALSE then we
  # raise a message and return the path of the .gpkg file.
  if (file.exists(gpkg_file_path) && isFALSE(force_vectortranslate)) {
    oe_message(
      "The corresponding gpkg file was already detected. ",
      "Skip vectortranslate operations.",
      quiet = quiet,
      .subclass = "oe_vectortranslate_skipOperations"
    )
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
      call. = FALSE
    )
    extra_tags = NULL
  }

  if (is.null(osmconf_ini)) {
    osmconf_ini = get_default_osmconf_ini()
  }

  # Add the extra tags to the default osmconf.ini. If the user set its own
  # osmconf.ini file we need to skip this step.
  if (
    !is.null(extra_tags) &&
    # The following condition checks whether the user set its own CONFIG file
    osmconf_ini == get_default_osmconf_ini()
  ) {
    temp_ini = readLines(osmconf_ini)
    id_layer = get_id_layer(layer, temp_ini)
    fields_old = get_fields_default(layer, temp_ini)
    temp_ini[[id_layer]] = paste0(
      "attributes=",
      paste(unique(c(fields_old, extra_tags)), collapse = ",")
    )
    temp_ini_file = tempfile(fileext = ".ini")
    writeLines(temp_ini, con = temp_ini_file)
    osmconf_ini = temp_ini_file
  }

  # If vectortranslate options is NULL (i.e. the default value), then we adopt
  # the following set of options:
  if (is.null(vectortranslate_options)) {
    vectortranslate_options = c(
      "-f", "GPKG", # output file format
      "-overwrite", # overwrite an existing file
      "-oo", paste0("CONFIG_FILE=", osmconf_ini), # open options
      "-lco", "GEOMETRY_NAME=geometry" # layer creation options
    )

    # Check if we need to add a spatial filter
    vectortranslate_options = process_boundary(
      vectortranslate_options,
      boundary,
      boundary_type
    )

    # Add the layer argument
    vectortranslate_options = c(vectortranslate_options, layer)
  } else {
    # Otherwise we check the options set by the user and append other basic
    # options:

    # 1. Check if the user omitted the "-f" option (which is used to select the
    # format_name)
    if ("-f" %!in% vectortranslate_options) {
      vectortranslate_options = c(vectortranslate_options, "-f", "GPKG")
    } else {
      which_f = which(vectortranslate_options == "-f")
      if (
        which_f == length(vectortranslate_options) ||
        vectortranslate_options[which_f + 1] != "GPKG"
      ) {
        oe_stop(
          .subclass = "oe_vectortranslate_shouldTranslateToGPKGOnly",
          message = "The oe_vectortranslate function should translate to GPKG format only"
        )
      }
    }

    #  Check if the user omitted the "-overwrite" option
    if ("-overwrite" %!in% vectortranslate_options && all(c())) {
      # Otherwise add the -overwrite option
      vectortranslate_options = c(vectortranslate_options, "-overwrite")
    }

    # Check if the user set any open option
    if ("-oo" %!in% vectortranslate_options) {
      # Otherwise append the basic open options
      vectortranslate_options = c(vectortranslate_options, "-oo", paste0("CONFIG_FILE=", osmconf_ini))
    } else {
      # Check if the user set its own CONFIG_FILE and osmconf_ini is not NULL.
      # In that case, raise a warning message
      if (any(grepl("CONFIG_FILE", vectortranslate_options)) && !is.null(osmconf_ini)) {
        warning(
          "The osmconf_ini argument is ignored since the CONFIG file ",
          "was already specified in the vectortranslate options.",
          call. = FALSE
        )
      }
    }

    # Check if the user set any layer creation option (lco)
    if ("-lco" %!in% vectortranslate_options) {
      # Otherwise append the basic layer creation options
      vectortranslate_options = c(vectortranslate_options, "-lco", "GEOMETRY_NAME=geometry")
    }

    # Check if the user set the argument boundary
    vectortranslate_options = process_boundary(vectortranslate_options, boundary, boundary_type)

    # Check if the user added the layer argument
    if (
      !any(c("points", "lines", "multipolygons", "multilinestrings", "other_relations") %in% vectortranslate_options)
    ) {
      # Otherwise append the layer
      vectortranslate_options = c(vectortranslate_options, layer)
    }
  }

  oe_message(
    "Starting with the vectortranslate operations on the input file!",
    quiet = quiet,
    .subclass = "oe_vectortranslate_startVectortranslate"
  )

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

  oe_message(
    "Finished the vectortranslate operations on the input file!",
    quiet = quiet,
    .subclass = "oe_vectortranslate_finishedVectortranslate"
  )

  # and return the path of the gpkg file
  gpkg_file_path
}

get_id_layer = function(layer, file) {
  # Detect the ID of the row which specifies the attributes that must be
  # included in the ogr2ogr conversion from .osm to .gpkg file for a given
  # layer. The following pattern uses a simple heuristic which is based on the
  # current (2024-11-12) structure of the osmconf.ini file, i.e. the attributes
  # are specified in a single row which starts with "attributes=". The available
  # layers are described below in that precise order. I need to make this ID
  # detection automatic for #261 so I do not need to link the ogr2ogr operations
  # to a fixed osmconf.ini file.
  id_attributes <- grepl(
    pattern = "^attributes=",
    x = file,
    perl = TRUE
  )
  id_attributes <- which(id_attributes)
  stopifnot(length(id_attributes) == 5L)
  stopifnot(layer %in% c("points", "lines", "multipolygons", "multilinestrings", "other_relations"))
  switch(
    layer,
    "points" = id_attributes[1L],
    "lines" = id_attributes[2L],
    "multipolygons" = id_attributes[3L],
    "multilinestrings" = id_attributes[4L],
    "other_relations" = id_attributes[5L]
  )
}
get_fields_default = function(layer, file) {
  # The following code is used to extract the default keys which must be
  # included in the ogr2ogr conversion from .osm to .gpkg format for a given
  # layer. The following pattern uses a simple heuristic which is based on the
  # current (2024-11-12) structure of the osmconf.ini file, i.e. the attributes
  # are specified in a single row which starts with "attributes=". This
  # automatic detection is required to implement #261.

  # I cannot simply use grep(value = TRUE) since that matches the whole row, not
  # only the part which I'm interested in. I need regexpr + regmatch
  m = regexpr(
    pattern = "(?<=^attributes=)\\S*",
    text = file,
    perl = TRUE
  )
  keys <- regmatches(x = file, m = m)
  # The output of regmatches is a (character vector) which includes the matched
  # substrings. It has a syntax like
  # [1] a,b,c,d
  # [2] a,d,e,f
  # [3] b,f,g
  # ...
  # I need to split such sequence of keys using "," as a delimiter.
  keys <- strsplit(keys, ",")
  # I assume there are 5 layers specified according to the following order:
  stopifnot(length(keys) == 5L)
  stopifnot(layer %in% c("points", "lines", "multipolygons", "multilinestrings", "other_relations"))
  # The output of strsplit is a list so I need [[i]] syntax.
  switch(
    layer,
    "points" = keys[[1L]],
    "lines" = keys[[2L]],
    "multipolygons" = keys[[3L]],
    "multilinestrings" = keys[[4L]],
    "other_relations" = keys[[5L]]
  )
}

process_boundary = function(
  vectortranslate_options,
  boundary = NULL,
  boundary_type = c("spat", "clipsrc")
) {
  # Checks
  if (is.null(boundary)) {
    return(vectortranslate_options)
  }

  if (any(c("-spat", "-clipsrc") %in% vectortranslate_options)) {
    warning(
      "The boundary argument is ignored since the vectortraslate_options ",
      "already defines a spatial filter",
      call. = FALSE
    )
    return(vectortranslate_options)
  }

  # Match the boundary type
  boundary_type = match.arg(boundary_type)

  # Extract/convert the geometry (or just return the geometry if boundary is a
  # sfc)
  if (inherits(boundary, "bbox")) {
    boundary = sf::st_as_sfc(boundary)
  }
  boundary = sf::st_geometry(boundary)

  # Check the number of geometries
  if (length(boundary) > 1L) {
    warning(
      "The boundary is composed by more than one features. Selecting the first. ",
      call. = FALSE
    )
    boundary = boundary[1L]
  }

  # Check that the object can be interpreted as a POLYGON
  stopifnot(sf::st_is(boundary, "POLYGON") || sf::st_is(boundary, "MULTIPOLYGON"))

  # Check the CRS of boundary
  if (sf::st_crs(boundary) != sf::st_crs(4326)) {
    boundary = sf::st_transform(boundary, 4326)
  }
  # Try to fix the boundary in case it's not valid
  if (! sf::st_is_valid(boundary)) {
    boundary = sf::st_make_valid(boundary)
  }

  # Add and return
  switch(
    boundary_type,
    spat = process_spat(vectortranslate_options, boundary),
    clipsrc = process_clipsrc(vectortranslate_options, boundary)
  )
}

# Add "-spat" + (xmin, ymin, xmax, ymax)
process_spat = function(vectortranslate_options, boundary) {
  c(vectortranslate_options, "-spat", sf::st_bbox(boundary))
}

# Add "-clipsrc" + WKT
process_clipsrc = function(vectortranslate_options, boundary) {
  c(vectortranslate_options, "-clipsrc", sf::st_as_text(boundary))
}

# Get default osmconf.ini
get_default_osmconf_ini <- function() {
  # I guess we have 3 options to retrieve the osmconf.ini file used by GDAL
  # 1. Check the output of gdal-config --datadir (if possible)
  # 2. Get the file bundled by sf (especially when using binary install of sf)
  # 3. Fallback: osmconf.ini file shipped by this package

  # Option 1
  file <- try({
    system2("gdal-config", args = "--datadir", stdout = TRUE)
    },
    silent = TRUE
  )
  if (!inherits(file, "try-error")) {
    return(file.path(file, "osmconf.ini"))
  }
  # Option 2
  file <- system.file("gdal/osmconf.ini", package = "sf")
  if (!file.exists(file)) {
    # Option 3
    warning(
      "The package couldn't retrive the osmconf.ini from GDAL installation. ",
      "Defaulting to the one bundled in this package. ",
      "Please raise a new issue at https://github.com/ropensci/osmextract/issues"
    )
    file <- system.file("osmconf.ini", package = "osmextract")
  }
  file
}
