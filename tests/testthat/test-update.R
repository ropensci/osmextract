test_that("oe_update(): simplest example works", {
  skip_on_ci() # I can just run these tests on local laptop
  skip_on_cran()
  # I always need internet connection when running oe_update()
  skip_if_offline("download.openstreetmap.fr")

  # Clean tempdir on exit + options
  withr::local_envvar(
    .new = list(
      "OSMEXT_DOWNLOAD_DIRECTORY" = tempdir(),
      "TESTTHAT" = "true"
    )
  )
  withr::defer(oe_clean(tempdir()))

  # I should also check the status code of the provider since there might be a
  # problem with the provider for whatever reason.
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

  bi <- oe_get("Bouvet Island", provider = "openstreetmap_fr", quiet = TRUE)

  # Simplest example
  expect_error(oe_update(quiet = TRUE), NA)

  # The oe_update() should have removed the .gpkg file
  expect_identical(
    object = list.files(oe_download_directory(), pattern = "gpkg$"),
    expected = character(0)
  )
})
