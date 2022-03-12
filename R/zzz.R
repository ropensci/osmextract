.onAttach = function(libname, pkgname) {
  packageStartupMessage(paste(
    "Data (c) OpenStreetMap contributors, ODbL 1.0. https://www.openstreetmap.org/copyright.",
    "Check the package website, https://docs.ropensci.org/osmextract/, for more details.",
    # See https://github.com/ropensci/osmextract/issues/156
    # "Any product made from OpenStreetMap must cite OSM as the data source.",
    # "Geofabrik data are taken from https://download.geofabrik.de/",
    # "For usage details of bbbike data see https://download.bbbike.org/osm/",
    # "OpenStreetMap_fr data are taken from http://download.openstreetmap.fr/",
    sep = "\n"
  ))

  # nocov start
  if (
    sf::sf_extSoftVersion()["GDAL"] < "3.0.0" ||
    sf::sf_extSoftVersion()["proj.4"] < "6.0.0"
  ) {
    packageStartupMessage(paste0(
      "The package may return several warning messages like\n",
      "'st_crs<- : replacing crs does not reproject data; use st_transform for that'\n",
      "They are caused by a version of GDAL that does not support WKT.",
      " The functions defined in this package should still work.",
      " Check the README for more details."
    ))
  }
  # nocov end
}
