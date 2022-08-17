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

test_that("oe_find: simplest example works", {
  its_pbf = setup_pbf()
  withr::local_envvar(
    .new = list("OSMEXT_DOWNLOAD_DIRECTORY" = tempdir())
  )

  oe_vectortranslate(
    file_path = its_pbf,
    quiet = TRUE
  )

  its_leeds_find = oe_find(
    "ITS Leeds",
    quiet = TRUE
  )
  expect_type(its_leeds_find, "character")
  expect_length(its_leeds_find, 2)
})

test_that("oe_find: return_gpkg and return_pbf arguments work", {
  its_pbf = setup_pbf()
  withr::local_envvar(
    .new = list("OSMEXT_DOWNLOAD_DIRECTORY" = tempdir())
  )

  oe_vectortranslate(
    file_path = its_pbf,
    quiet = TRUE
  )

  pbf_find = oe_find(
    "ITS Leeds",
    quiet = TRUE,
    return_gpkg = FALSE
  )
  gpkg_find = oe_find(
    "ITS Leeds",
    quiet = TRUE,
    return_pbf = FALSE
  )

  expect_length(pbf_find, 1)
  expect_length(gpkg_find, 1)

  expect_type(pbf_find, "character")
  expect_type(gpkg_find, "character")

  expect_match(pbf_find, "pbf")
  expect_match(gpkg_find, "gpkg")
})

test_that("download_if_missing in oe_find works", {
  skip_on_cran()
  skip_if_offline("github.com")
  withr::defer(oe_clean(tempdir()))
  withr::local_envvar(
    .new = list("OSMEXT_DOWNLOAD_DIRECTORY" = tempdir())
  )

  # Test that tempdir is really empty
  expect_true(!file.exists(file.path(tempdir(), "test_its-example.osm.pbf")))

  # Test download_if_missing
  its_leeds_find = oe_find(
    "ITS Leeds",
    provider = "test",
    download_if_missing = TRUE,
    quiet = TRUE
  )
  expect_type(its_leeds_find, "character")
  expect_length(its_leeds_find, 2)
})
