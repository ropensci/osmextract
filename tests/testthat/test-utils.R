################################################################################
# NB: ALWAYS REMEMBER TO SET                                                   #
# withr::local_envvar(                                                         #
#   .new = list("OSMEXT_DOWNLOAD_DIRECTORY" = tempdir())                       #
# )                                                                            #
# IF YOU NEED TO MODIFY THE OSMEXT_DOWNLOAD_DIRECTORY envvar INSIDE THE TESTS. #
#                                                                              #
# I could also set the same option at the beginning of the script but that     #
# makes the debugging more difficult since I have to manually reset the        #
# options at the end of the debugging process.                                 #
#                                                                              #
# See R/test-helpers.R for more details                                        #
#                                                                              #
################################################################################

test_that("oe_clean removes all files in download_directory", {
  withr::defer(oe_clean(tempdir()))

  file.copy(
    from = system.file("its-example.osm.pbf", package = "osmextract"),
    to = file.path(tempdir(), "test_its-example.osm.pbf")
  )

  oe_clean(tempdir())

  expect_equal(
    object = list.files(tempdir(), "\\.(pbf|gpkg)$", full.names = TRUE),
    expected = character(0)
  )
})
