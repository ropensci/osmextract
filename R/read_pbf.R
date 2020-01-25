#' Read pbf files with additional attributes
#'
#' Read pbf files (typically downloaded with [`get_geofabrik()`]) after
#' translating the `.osm.pbf` format into a `.gpkg` format. See details.
#'
#' @inheritParams make_additional_attributes
#' @param dsn The location of the file
#' @param key Character string defining the key values to subset the data from,
#'   e.g. `"highway"`.
#' @param value The value(s) the `key` can take, e.g. `"cycleway"`
#' @param selected_columns The columns to return in the output
#' @param ini_file A modified version of
#'   <https://github.com/OSGeo/gdal/raw/master/gdal/data/osmconf.ini> If NULL (the
#'   default), then it's created using [`make_ini_attributes()`] function.
#' @param vectortranslate_options Character vector that specify the options
#'   passed to ogr2ogr. See details.
#'
#' @details
#' This function is used to read `.osm.pbf` files using the following procedure.
#' First the `.osm.pbf` file is translated into a `.gpkg` file using
#' `vectortranslate` [gdal utils](https://gdal.org/programs/ogr2ogr.html) via
#' [`sf::gdal_utils()`].
#' Then, the .gpkg file is read using [`sf::read_sf()`] function.
#' Read the discussion in <https://github.com/ITSLeeds/geofabrik/issues/12> and
#' <https://github.com/OSGeo/gdal/issues/2100> for an explanation of this
#' procedure.
#'
#' The `vectortranslate_options` parameter is used to control the behaviour of
#' `vectortranslate` utils. If `NULL` (the default), then the following options
#' are added:
#'
#' - "-f", "GPKG",
#' - "-overwrite",
#' - "-oo", "CONFIG_FILE=*ini_file*",
#' - "-lco", "GEOMETRY_NAME=geometry",
#' - *layer*
#'
#' Check [ogr2ogr2](https://gdal.org/programs/ogr2ogr.html) documentation for a
#' complete list of all available operations and [`sf::gdal_utils()`] for
#' examples on how to specify the options parameter.
#' The strings `c("-f", "GPKG")` are used to specify the desired output format
#' (GPKG in this case).
#' The third string is used to set the `overwrite` option.
#' The fourth and fifth strings are used to set the GDAL OSM driver [Open
#' Options](https://gdal.org/drivers/vector/osm.html#open-options) and overwrite
#' the default CONFIG_FILE with *ini_file* parameter to read additional
#' attributes.
#' The last two strings are used to set the GPKG Layer Creation Options and fix
#' <https://github.com/ITSLeeds/geofabrik/issues/36>.
#' The last parameter specifies the desired layer.
#'
#' @export
#' @examples
#' \donttest{
#' pbf_url = geofabrik_zones$pbf_url[geofabrik_zones$name == "Isle of Wight"]
#' f = file.path(tempdir(), "test.osm.pbf")
#' download.file(pbf_url, f)
#' # testing read_sf
#' sf::st_layers(f)
#' res = sf::read_sf(f, layer = "lines") # works
#' res = sf::read_sf(f, layer = "lines", query = "select * from lines") # works
#' res = sf::read_sf(f, layer = "multipolygons", query = "select * from multipolygons") # works
#' q = "select * from lines where highway = 'cycleway'"
#' res_cycleways = sf::read_sf(f, layer = "lines", query = q)
#' res_cycleways = read_pbf(f, key = "highway", value = "cycleway") # more concise
#' res = read_pbf(f)
#' names(res)
#' res = read_pbf(f, layer = "points")
#' names(res)
#' res = read_pbf(f, selected_columns = "highway") # only return highway column
#' names(res)
#' res_cycleway = res = read_pbf(f, layer = "lines", key = "highway", value = "cycleway")
#' plot(res_cycleway)
#' # uncomment to get big dataset
#' # f_en = gf_filename("England")
#' # u_en = geofabrik_zones$pbf_url[geofabrik_zones$name == "England"]
#' # download.file(u_en, f_en)
#' # cycleway_en = read_pbf(f_en, layer = "lines", key = "highway", value = "cycleway")
#' # plot(cycleway_en$geometry)
#' # pryr::object_size(cycleway_en)
#' }
read_pbf = function(dsn,
                    layer = "lines",
                    key = NULL,
                    value = NULL,
                    selected_columns = "*",
                    ini_file = NULL,
                    attributes = make_additional_attributes(layer = layer),
                    append = TRUE,
                    vectortranslate_options = NULL
                    ) {
  if(is.null(ini_file)) {
    ini_file = file.path(tempdir(), "ini_new.ini")
    ini_new = make_ini_attributes(attributes = attributes, layer = layer, append = TRUE)
    writeLines(ini_new, ini_file)
  }
  # Translate .osm.pbf file into a .gpkg format
  gpkg_file <- paste0(tempfile(), ".gpkg")
  if (is.null(vectortranslate_options)) {
    vectortranslate_options <- c(
      "-f", "GPKG", # define output format, i.e. gpkg
      "-overwrite",
      "-oo", paste0("CONFIG_FILE=", ini_file),
      "-lco", "GEOMETRY_NAME=geometry", # fix https://github.com/ITSLeeds/geofabrik/issues/36
      layer
    )
  }
  sf::gdal_utils(
    util = "vectortranslate",
    source = dsn,
    destination = gpkg_file,
    options = vectortranslate_options
  )

  query = paste0("select ", selected_columns, " from ", layer)
  if(!is.null(key)) {
    if(is.null(value)) {
      value = "*"
    }
    query = paste0(query, " where ", key, " = '", value,"'")
  }
  message("Using ini file that can can be edited with file.edit(", ini_file, ")")
  res = sf::read_sf(gpkg_file, layer = layer, query = query)
}


#' Get modified version of config file for reading .pbf files with GDAL/sf
#'
#' This function provides a user friendly interface to the [GDAL OSM driver](https://gdal.org/drivers/vector/osm.html)
#' via `sf`. See https://github.com/r-spatial/sf/issues/1157 for details.
#'
#' Default additional attributes were taken from https://taginfo.openstreetmap.org/keys
#'
#' @param attributes Vector of character strings naming attributes to import
#' @param layer Which layer to read in? One of
#' "points"           "lines"            "multipolygons"    "multilinestrings" or "other_relations"
#' @param defaults The default attributes
#' @param append Should the columns named in `attributes` be appended to the default columns?
#' `TRUE` by default.
#'
#' @return
#' A character vector representing an ini file.
#' @export
#' @examples
#' \donttest{
#' make_ini_attributes("oneway", "lines")
#' }
make_additional_attributes = function(layer) {
  l = list(
    points = c(
      "building",
      "natural",
      "surface",
      "source",
      "power",
      "amenity",
      "shop",
      "operator"
    ),
    lines = c(
      "maxspeed",
      "oneway",
      "building",
      "surface",
      "landuse",
      "natural",
      "start_date",
      "wall",
      "service",
      "lanes",
      "layer",
      "tracktype",
      "bridge",
      "foot",
      "bicycle",
      "lit",
      "railway",
      "footway"
    ),
    multipolygons = c("start_date", "locality", "symbol", "naptan:StopAreaCode", "naptan:StopAreaType", "naptan:verified", "highway"),
    multilinestrings = c("start_date", "locality", "symbol", "naptan:StopAreaCode", "naptan:StopAreaType", "naptan:verified", "highway"),
    other_relations = c("start_date", "locality", "symbol", "naptan:StopAreaCode", "naptan:StopAreaType", "naptan:verified", "highway")
  )
  l[[layer]]
}
#' @export
#' @rdname make_additional_attributes
make_ini_attributes = function(attributes,
                               layer,
                               defaults = get_ini_layer_defaults(layer),
                               append = TRUE) {
  attributes_default_ini = paste0("attributes=", paste(defaults, collapse = ","))
  if (append) {
    attributes = c(defaults, attributes)
  }
  attributes_default_ini_new = paste0("attributes=", paste(attributes, collapse = ","))
  ini_file = readLines("https://github.com/OSGeo/gdal/raw/master/gdal/data/osmconf.ini")
  sel_attributes = grepl(pattern = attributes_default_ini, x = ini_file)
  message("Old attributes: ", ini_file[sel_attributes])
  message("New attributes: ", attributes_default_ini_new)
  ini_file[sel_attributes] = attributes_default_ini_new
  ini_file
}

get_ini_layer_defaults = function(layer) {
  # generate defaults for layer attributes
  # ini_file = readLines("https://github.com/OSGeo/gdal/raw/master/gdal/data/osmconf.ini")
  # attributes = ini_file[grepl(pattern = "^attributes=", ini_file)]
  # layer_names = ini_file[grepl(pattern = "^\\[", x = ini_file)]
  # layer_names = gsub(pattern = "\\[|\\]", replacement = "", x = layer_names)
  # attributes = gsub(pattern = "attributes=", "", attributes)
  # l = sapply(attributes, function(x) names(read.csv(text = x)))
  # class(l)
  # names(l) = layer_names
  # dput(l)
  l = list(
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
  l[[layer]]
}
