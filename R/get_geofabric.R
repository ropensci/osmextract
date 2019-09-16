#' Download street network data
#' @export
#' @examples
#' get_geofabric(country = "great-britain")
#' get_geofabric(country = "italy")
#' get_geofabric(country = "italy", region = "nord-est")
get_geofabric = function(continent = "europe",
                         country = "great-britain",
                         region = NULL,
                         download_directory = tempdir(),
                         unzip_directory = tempdir()) {
  country_only = country_url = paste0(
    "http://download.geofabrik.de/",
    continent,
    "/",
    country
  )
  if(!is.null(region)) {
    country_url = paste0(country_url, "/", region)
  }
  country_url = paste0(country_url, "-latest-free.shp.zip")
  message("Trying ", country_url)
  res = httr::GET(country_url)
  url_ok = identical(httr::status_code(res), 200L)
  if(!url_ok) {
    message("No country file to download. See ", country_only, " for available regions.")
    return(country_only)
  }
  message("Downloading ", country_url)
  download_path = file.path(download_directory, paste0(country, ".zip"))
  download.file(url = country_url, destfile = download_path)
  unzip(zipfile = download_path, exdir = unzip_directory)
  message("The following shapefiles have been downloaded:")
  shapefiles = list.files(path = unzip_directory, pattern = ".shp")
  return(shapefiles)
}

