# Auxiliary functions (not exported)
'%!in%' = function(x, y) !('%in%'(x,y))

# The following function is used to extract the OSMEXT_DOWNLOAD_DIRECTORY
# environment variable.
oe_download_directory = function() {
  download_directory = Sys.getenv("OSMEXT_DOWNLOAD_DIRECTORY", "")
  if (download_directory == "") {
    download_directory = tempdir()
  }
  if (!dir.exists(download_directory)) {
    dir.create(download_directory)
  }
  download_directory
}
