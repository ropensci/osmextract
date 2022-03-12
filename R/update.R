#' Update all the .osm.pbf files saved in a directory
#'
#' This function is used to re-download all `.osm.pbf` files stored in
#' `download_directory` that were firstly downloaded through [oe_get()]. See
#' Details.
#'
#' @param download_directory Character string of the path of the directory
#'   where the `.osm.pbf` files are saved.
#' @param quiet Boolean. If `FALSE` the function prints informative
#'   messages. See Details.
#' @param delete_gpkg Boolean. if `TRUE` the function deletes the old `.gpkg`
#'   files. We added this parameter to minimize the probability of accidentally
#'   reading-in old and not-synchronized `.gpkg` files. See Details. Defaults to
#'   `TRUE`.
#' @param max_file_size The maximum file size to download without asking in
#'   interactive mode. Default: `5e+8`, half a gigabyte.
#' @param ... Additional parameter that will be passed to [oe_get()] (such as
#'   `stringsAsFactors` or `query`).
#'
#' @details This function is used to re-download `.osm.pbf` files that are
#'   stored in a directory (specified by `download_directory` param) and that
#'   were firstly downloaded through [oe_get()] . The name of the files must
#'   begin with the name of one of the supported providers (see
#'   [oe_providers()]) and it must end with `.osm.pbf`. All other
#'   files in the directory that do not match this format are ignored.
#'
#'   The process for re-downloading the `.osm.pbf` files is performed using the
#'   function [oe_get()] . The appropriate provider is determined by looking at
#'   the first word in the path of the `.osm.pbf` file. The place is determined
#'   by looking at the second word in the file path and the matching is
#'   performed through the `id` column in the provider's database. So, for
#'   example, the path `geofabrik_italy-latest-update.osm.pbf` will be matched
#'   with the provider `"geofabrik"` and the geographical zone `italy` through
#'   the column `id` in `geofabrik_zones`.
#'
#'   The parameter `delete_gpkg` is used to delete all `.gpkg` files in
#'   `download_directory`. We decided to set its default value to `TRUE` to
#'   minimize the possibility of reading-in old and non-synchronized `.gpkg`
#'   files. If you set `delete_gpkg = FALSE`, then you need to manually
#'   reconvert all files using [oe_get()] or [oe_vectortranslate()] .
#'
#'   If you set the parameter `quiet` to `FALSE`, then the function will print
#'   some useful messages regarding the characteristics of the files before and
#'   after updating them. More precisely, it will print the output of the
#'   columns `size`, `mtime` and `ctime` from [file.info()]. Please note that
#'   the meaning of `mtime` and `ctime` depends on the OS and the file system.
#'   Check [file.info()].
#'
#' @return The path(s) of the `.osm.pbf` file(s) that were updated.
#' @export
#' @examples
#' \dontrun{
#' # Set up a fake directory with .pbf and .gpkg files
#' fake_dir = tempdir()
#' # Fill the directory
#' oe_get("Andorra", download_directory = fake_dir, download_only = TRUE)
#' # Check the directory
#' list.files(fake_dir, pattern = "gpkg|pbf")
#' # Update all .pbf files and delete all .gpkg files
#' oe_update(fake_dir, quiet = TRUE)
#' list.files(fake_dir, pattern = "gpkg|pbf")}
oe_update = function(
  download_directory = oe_download_directory(),
  quiet = FALSE,
  delete_gpkg = TRUE,
  max_file_size = 5e+8,
  ...
) {
  # Extract all files in download_directory
  all_files = list.files(download_directory)

  # Save all providers
  all_providers = oe_available_providers()

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
  if (isFALSE(quiet)) {
    old_files_info = file.info(file.path(download_directory, all_files))
    cat(
      "This is a short description of some characteristics of all the files",
      "saved in the download_directory: \n"
    )
    print(old_files_info[, c(1, 4, 5)])
    cat("\nThe .osm.pbf files are going to be updated.\n")
  }

  # Check if the .gpkg files should be deleted
  if (isTRUE(delete_gpkg)) {
    if (isFALSE(quiet)) {
      cat("The .gpkg files are going to be removed.\n")
    }
    file.remove(
      file.path(download_directory, grep("\\.gpkg", all_files, value = TRUE))
    )
    if (isFALSE(quiet)) {
      cat("The .gpkg files in download_directory were removed.\n")
    }
  }

  # Find all files with the following pattern: provider_whatever.osm.pbf
  providers_regex = paste0(all_providers, collapse = "|")
  oe_regex = paste(
    "(", providers_regex, ")", # match with geofabrik or bbbike or ...
    "_(.+)", # match with everything
    "\\.osm\\.pbf", # match with ".osm.pbf" (i.e. exclude .gpkg)
    collapse = "",
    sep = ""
  )
  osmpbf_files = grep(oe_regex, all_files, perl = TRUE, value = TRUE)

  # Check if any file is bigger than 5e+8 bytes (500MB) and, in that case, it prompts an
  # interactive menu or set max_file_size = Inf
  if (any(file.size(file.path(download_directory, osmpbf_files)) > 5e+8)) {
    continue = 1L
    if (interactive()) {
      message("You are going to download one or more file(s) bigger than 500MB")
      continue = utils::menu(
        choices = c("Yes", "No"),
        title = "Are you sure that you want to proceed?"
      )

      if (continue != 1L) {
        stop("Aborted by user.", call. = FALSE)
      }
    }

    max_file_size = Inf
  }

  # For all the files matched with the previous regex
  for (file in osmpbf_files) {
    # Match it's provider.
    provider = regmatches(
      file,
      regexpr(paste0("^(", paste0(all_providers, collapse = "|"), ")"), text = file, perl = TRUE)
    )

    # Match the id of the place (the id is the alphabetic string right  after
    # the provider, for example if file is equal to
    # geofabrik_italy-latest-update.osm.pbf then provider = geofabrik and id =
    # italy). The regex is different for bbbike provider since it doesn't use
    # the term "-latest" before .osm.pbf.
    # I added the term "-" and "_" to the second regex since they may be
    # included in several id(s).
    if (provider %in% c("bbbike", "test")) {
      id = regmatches(
        file,
        regexpr(paste0("(?<=", provider, "_)[A-Za-z]+"), file, perl = TRUE)
      )
    } else {
      id = regmatches(
        file,
        regexpr(paste0("(?<=", provider, "_)[a-zA-Z-_]+(?=-latest)"), file, perl = TRUE)
      )
    }

    # The ID of the US states is "us/state" while the name is just "state", so I
    # need to check if the id is one of the US states and then add the "us/"
    # prefix.
    if (id %in% gsub("us/", "", oe_match_pattern("us/"))) {
      id = paste0("us/", id)
    }

    # Print a message
    oe_message(
      "The function is processing the file ", file, ".",
      quiet = quiet
    )

    # Update the .osm.pbf files, skipping the vectortranslate step
    oe_get(
      place = id,
      provider = provider,
      match_by = "id",
      force_download = TRUE,
      download_only = TRUE,
      skip_vectortranslate = TRUE,
      max_file_size = max_file_size,
      quiet = quiet,
      # The files should always be updated in that download_directory (which may
      # not be the default one)
      download_directory = download_directory,
      ...
    )
  }

  # A summary of the files in download_directory
  if (isFALSE(quiet)) {
    new_files_info = file.info(file.path(download_directory, osmpbf_files))
    cat(
      "This is a short description of some characteristics of the updated",
      " files stored in the download_directory: \n"
    )
    print(new_files_info[, c(1, 4, 5)])
  }

  osmpbf_files
}
