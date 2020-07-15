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
#' TODO: 1) Add explanation of the meaning of mtime and ctime (?file.info); 3) Add .gpkg stuff
#' @examples
#' 1 + 1
oe_update = function(
  download_directory = oe_download_directory(),
  oe_verbose = TRUE
) {
  # Extract all files in download_directory
  all_files = list.files(download_directory)

  # Save all providers but test
  all_providers = setdiff(oe_available_providers(), "test")

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
    cat("\nNow the .osm.pbf files are going to be updated.\n")
  }

  # Find all files with the following pattern: provider_something.osm.pbf
  providers_regex = paste0(all_providers, collapse = "|")
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
    matching_providers = vapply(all_providers, grepl, FUN.VALUE = logical(1), x = file, fixed = TRUE)
    provider = all_providers[matching_providers]
    id = regmatches(
      file,
      regexpr(paste0("(?<=", provider, "_)[a-zA-Z]+"), file, perl = TRUE)
    )

    oe_get(
      place = id,
      provider = provider,
      match_by = "id",
      force_download = TRUE,
      download_only = TRUE,
      skip_vectortranslate = TRUE
    )
  }
}



