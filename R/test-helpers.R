# This (unexported) function is used to implement the so-called test-fixtures:
# https://testthat.r-lib.org/articles/test-fixtures.html#test-fixtures. The idea
# is to automatically run some specific tasks (see below) before and after each
# test and "leave the world exactly as we found it". More precisely, the
# function performs the follwing steps:

# 1. Setup the cleaning of all pbf/gpkg files in the folder where "path" is
# defined
# 2. Copy the "its-example.osm.pbf" file to "path"
# 3. Return that "path" (invisibly)

setup_pbf <- function(path, env = parent.frame()) {
  withr::defer({
    oe_clean(dirname(path), force = TRUE)
  }, envir = env)

  file.copy(
    from = system.file("its-example.osm.pbf", package = "osmextract"),
    to = path
  )

  invisible(path)
}

# NB: It might be quite boring to debug the tests interactively since the
# options in "tests/testthat/setup-tests.R" are set only by devtools::test. For
# this reason, I copied the same code to "tests/testthat/help-tests.R" since
# that file is also run by "devtools::load_all()". The only problem is that I
# need to restart the R session at the end of each test to reset those options.
# At the moment, I commented all the code since I don't need those options every
# time I run load_all().

