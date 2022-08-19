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
# See R/test-helpers.R for more details.                                       #
#                                                                              #
# NB2: I don't need to set withr::defer when using setup_pbf() since that      #
# function automatically sets it.                                              #
#                                                                              #
################################################################################

test_that("oe_get_network: simplest examples work", {
  its_pbf = setup_pbf()
  withr::local_envvar(
    .new = list("OSMEXT_DOWNLOAD_DIRECTORY" = tempdir())
  )

  expect_error(oe_get_boundary("ITS Leeds", quiet = TRUE), NA)
})
