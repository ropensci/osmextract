# This (unexported) function is used to implement the so-called test-fixtures:
# https://testthat.r-lib.org/articles/test-fixtures.html#test-fixtures. The idea
# is to automatically run some specific tasks (see below) before and after each
# test and "leave the world exactly as we found it". More precisely, the
# function performs the follwing steps:

# 1. Setup the cleaning of all pbf/gpkg files in the folder where "path" is
# defined using oe_clean.
# 2. Copy the "its-example.osm.pbf" file to "path"
# 3. Return that "path" (invisibly)

# The returned path is used to define the "its_pbf" variable inside each test.

setup_pbf <- function(
    path = file.path(tempdir(), "test_its-example.osm.pbf"),
    env = parent.frame()
  ) {
  withr::defer({
    oe_clean(dirname(path), force = TRUE)
  }, envir = env)

  file.copy(
    from = system.file("its-example.osm.pbf", package = "osmextract"),
    to = path
  )

  invisible(path)
}
