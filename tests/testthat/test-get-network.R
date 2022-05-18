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

test_that("oe_get_network: simplest examples work", {
  its_pbf = setup_pbf()
  withr::local_envvar(
    .new = list("OSMEXT_DOWNLOAD_DIRECTORY" = tempdir())
  )

  expect_error(oe_get_network("ITS Leeds", quiet = TRUE), NA)
})

test_that("oe_get_network: options in ... work correctly", {
  its_pbf = setup_pbf()
  withr::local_envvar(
    .new = list("OSMEXT_DOWNLOAD_DIRECTORY" = tempdir())
  )

  expect_warning(oe_get_network("ITS Leeds", layer = "points", quiet = TRUE))
  expect_message(oe_get_network("ITS Leeds", quiet = TRUE), NA)

  driving_network_with_area_tag = oe_get_network(
    "ITS Leeds",
    mode = "driving",
    extra_tags = "area",
    quiet = TRUE
  )
  expect_true("area" %in% colnames(driving_network_with_area_tag))

  # Cannot use -where arg
  expect_error(oe_get_network(
    place = "ITS Leeds",
    quiet = TRUE,
    vectortranslate_options = c("-where", "ABC")
  ))

  walking_network_27700 = oe_get_network(
    "ITS Leeds",
    mode = "walking",
    vectortranslate_options = c("-t_srs", "EPSG:27700"),
    quiet = TRUE
  )
  expect_true(sf::st_crs(walking_network_27700) == sf::st_crs(27700))
})
