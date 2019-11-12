#' Read pbf files with additional attributes
#'
#' @inheritParams make_additional_attributes
#' @param dsn The location of the file
#' @param ini_file A modified version of https://github.com/OSGeo/gdal/raw/master/gdal/data/osmconf.ini
#'
#' @export
#' @examples
#' \donttest{
#' pbf_url = geofabric_zones$pbf_url[geofabric_zones$name == "Isle of Wight"]
#' f = file.path(tempdir(), "test.osm.pbf")
#' download.file(pbf_url, f)
#' res = read_pbf(f)
#' names(res)
#' res = read_pbf(f, layer = "points")
#' names(res)
#' }
read_pbf = function(dsn,
                    layer = "lines",
                    attributes = make_additional_attributes(layer = layer),
                    ini_file = NULL,
                    append = TRUE) {
  if(is.null(ini_file)) {
    ini_file = file.path(tempdir(), "ini_new.ini")
    ini_new = make_ini_attributes(attributes = attributes, layer = layer, append = TRUE)
    writeLines(ini_new, ini_file)
  }
  message("Using ini file that can can be edited with file.edit(", ini_file, ")")
  config_options = paste0("CONFIG_FILE=", ini_file)
  res = sf::read_sf(dsn = dsn, layer = layer, options = config_options)
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
