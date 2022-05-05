# This (unexported) function is used to implement the so-called test-fixtures:
# https://testthat.r-lib.org/articles/test-fixtures.html#test-fixtures.

# The idea is to automatically run some specific tasks (see below) before and
# after each test and "leave the world exactly as we found it". More precisely,
# the function performs the follwing steps:

# 1. Setup the cleaning of all pbf/gpkg files in the folder where "path" is
# defined using oe_clean.
# 2. Copy the "its-example.osm.pbf" file to "path". Default value is a file
# named "test_its-example.osm.pbf" inside tempdir(). The naming is important
# since it's the same pattern created by oe_get("ITS Leeds") and we can mimic
# the behaviour more precisely.
# 3. Return that "path" (invisibly). This is important since the returned path
# is used to define the "its_pbf" variable inside each test using the following
# pattern:
#
# its_pbf = setup_pbf()
#
# NB: The tests are typically run setting the tempdir() as the
# download_directory. This is achieved setting the OSMEXT_DOWNLOAD_DIR
# enviromental variable equal to tempdir() through a temporal change of the
# enviromental variable. See withr::local_envvar calls in tests/testthat.

setup_pbf <- function(
    path = file.path(tempdir(), "test_its-example.osm.pbf"),
    env = parent.frame()
  ) {
  withr::defer({
    oe_clean(dirname(path), force = TRUE)
  }, envir = env)

  # Just to be sure that there is no pbf/gpkg file in the chosen di
  if (!identical(
    list.files(dirname(path), "\\.(osm\\.pbf|gpkg)$", full.names = TRUE),
    character(0)
  )) {
    stop("There is one or leftover pbf/gpkg file. Check tests.", call. = FALSE)
  }

  file.copy(
    from = system.file("its-example.osm.pbf", package = "osmextract"),
    to = path
  )

  invisible(path)
}
