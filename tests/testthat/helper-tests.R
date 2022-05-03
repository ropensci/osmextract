# NB: It might be quite boring to debug the tests interactively since the
# options in tests/testthat/setup-tests.R are set only by devtools::test. For
# this reason, I copied the same code to "tests/testthat/help-tests.R" since
# this file is also run by "devtools::load_all()". The only problem is that I
# need to restart the R session at the end of each test to reset those options.
# At the moment, I commented all the code since I don't need those options every
# time I run load_all().

# # 1. Define the path where the ITS test file will be copied
# its_pbf = file.path(tempdir(), "test_its-example.osm.pbf")
#
# # 2. Force the OSMEXT_DOWNLOAD_DIRECTORY to be equal to tempdir()
# Sys.setenv("OSMEXT_DOWNLOAD_DIRECTORY" = tempdir())
