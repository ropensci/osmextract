.onAttach = function(libname, pkgname) {
  packageStartupMessage(paste(
    "Data (c) OpenStreetMap contributors, ODbL 1.0. https://www.openstreetmap.org/copyright.",
    "Any product made from OpenStreetMap must cite OSM as the data source.",
    "Geofabrik data are taken from https://download.geofabrik.de/",
    "For usage details of bbbike data see https://download.bbbike.org/osm/",
    sep = "\n"
  ))
}
