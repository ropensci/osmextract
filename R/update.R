#' Update all the files stores in download_directory
#'
#' This function is used to re-download all .osm.obf files stored in
#' `download_directory`
#'
#' @param download_directory Character string of the path of the directory where
#'   the files are saved.
#' @param oe_verbose Boolean. If `TRUE` the function prints informative messages.
#'
#' @return Not sure
#' @export
#'
#' @details
#' TODO: 1) Add explanation of the meaning of mtime and ctime (?file.info); 2)
#' Exclude test from the providers; 3) Add .gpkg stuff
#' @examples
#' 1 + 1
oe_update = function(
  download_directory = oe_download_directory(),
  oe_verbose = TRUE
) {
  # Extract all files in download_directory
  all_files = list.files(download_directory)

  # The following is used to check if the directory is empty since list.files
  # returns character(0) in case of empty dir
  if (identical(list.files(download_directory), character(0))) {
    stop(
      "The download directory, ",
      download_directory,
      ", is empty.",
      call. = FALSE
    )
  }
  # A summary of the files in download_directory
  if (isTRUE(oe_verbose)) {
    old_files_info = file.info(file.path(download_directory, all_files))
    cat(
      "This is a short description of some characteristics of the files",
      "stored in the download_directory: \n"
    )
    print(old_files_info[, c(1, 4, 5)])
    cat("Now the .osm.pbf files are going to be updated")
  }

  # Find all files with the following pattern: provider_something.osm.pbf
  providers_regex = paste0(oe_available_providers(), collapse = "|")
  oe_regex = paste(
    "(", providers_regex, ")", # match with geofabrik or bbbike or ...
    "_(.+)", # match with everything
    "\\.osm\\.pbf", # match with ".osm.pbf" (i.e. exclude .gpkg)
    collapse = "",
    sep = ""
  )
  osmpbf_files = grep(oe_regex, all_files, perl = TRUE, value = TRUE)

  browser()
  for (file in osmpbf_files) {
    file_split = strsplit(file, split = "_")

  }
}

# p = "geofabrik_andorra-latest.gpkg"
# strsplit(p, split = "_")
