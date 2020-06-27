.onAttach <- function(libname, pkgname) {
  packageStartupMessage(paste(
    "Data (c) OpenStreetMap contributors, ODbL 1.0. https://www.openstreetmap.org/copyright",
    "Geofabrik data are taken from https://download.geofabrik.de/",
    sep = "\n"
  ))
}
