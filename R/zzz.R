.onAttach = function(libname, pkgname) {
  packageStartupMessage(paste(
    "Data (c) OpenStreetMap contributors, ODbL 1.0. https://www.openstreetmap.org/copyright.",
    "Any product made from OpenStreetMap must cite OSM as the data source.",
    "Geofabrik data are taken from https://download.geofabrik.de/",
    "For usage details of bbbike data see https://download.bbbike.org/osm/",
    "OpenStreetMap_fr data are taken from http://download.openstreetmap.fr/",
    sep = "\n"
  ))
}

.onLoad = function(libname, pkgname) {
  if (
    sf::sf_extSoftVersion()["GDAL"] < "3.0.0" ||
    sf::sf_extSoftVersion()["proj.4"] < "6.0.0"
  ) {
    warning(
      "The package may return several warning messages like\n",
      "'st_crs<- : replacing crs does not reproject data; use st_transform for that'\n",
      "They are caused by a version of GDAL that does not support WKT.",
      " The functions defined in this package should still work.",
      " Check the README for more details."
    )
  }
}
