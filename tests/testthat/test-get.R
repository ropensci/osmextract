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

test_that("oe_get: simplest examples work", {
  skip_on_cran()
  skip_if_offline("github.com")
  withr::defer(oe_clean(tempdir()))
  withr::local_envvar(
    .new = list("OSMEXT_DOWNLOAD_DIRECTORY" = tempdir())
  )

  expect_s3_class(
    oe_get("ITS Leeds", provider = "test", quiet = TRUE),
    "sf"
  )
})

test_that("We can specify a path using ~", {
  # I think that we cannot safely add a directory on CRAN tests
  # See also https://github.com/ropensci/osmextract/issues/175
  skip_on_cran()
  skip_if_offline("github.com")
  withr::defer(unlink("~/test_for_tilde_in_R_osmextract", recursive = TRUE))

  dir.create("~/test_for_tilde_in_R_osmextract")
  expect_s3_class(
    object = oe_get(
      place = "ITS Leeds",
      download_directory = "~/test_for_tilde_in_R_osmextract",
      quiet = TRUE
    ),
    class = "sf"
  )

})

test_that("The provider is overwritten when oe_match finds a different provider", {
  # See https://github.com/ropensci/osmextract/issues/245
  withr::defer(oe_clean(tempdir()))
  withr::local_envvar(
    .new = list("OSMEXT_DOWNLOAD_DIRECTORY" = tempdir())
  )

  skip_on_ci() # I can just run these tests on local laptop
  skip_on_cran()
  skip_if_offline("download.openstreetmap.fr")

  # I should also check the status code of the provider
  my_status <- try(
    httr::status_code(
      httr::GET(
        "https://download.openstreetmap.fr/",
        httr::timeout(15L)
      )
    ),
    silent = TRUE
  )
  skip_if(inherits(my_status, "try-error"))
  skip_if_not(my_status == 200L)

  expect_match(
    oe_get("Sevastopol", download_only = TRUE, skip_vectortranslate = TRUE, quiet = TRUE),
    regexp = "openstreetmap_fr"
  )
})


