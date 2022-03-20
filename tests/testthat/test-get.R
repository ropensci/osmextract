test_that("oe_get: simplest examples work", {
  # Clean tempdir
  on.exit(
    oe_clean(tempdir()),
    add = TRUE,
    after = TRUE
  )

  # since it requires internet connection
  skip_on_cran()
  skip_if_offline("github.com")

  expect_s3_class(
    oe_get("ITS Leeds", provider = "test", quiet = TRUE, download_directory = tempdir()),
    "sf"
  )
})

test_that("We can specify path using ~", {
  # I think that we cannot safely add a directory on CRAN tests
  # See also https://github.com/ropensci/osmextract/issues/175
  skip_on_cran()
  skip_if_offline("github.com")

  dir.create("~/test_for_tilde_in_R_osmextract")
  expect_s3_class(
    object = oe_get(
      place = "ITS Leeds",
      download_directory = "~/test_for_tilde_in_R_osmextract",
      quiet = TRUE
    ),
    class = "sf"
  )
  unlink("~/test_for_tilde_in_R_osmextract", recursive = TRUE)
})

test_that("The provider is overwritten when oe_match find a different provider", {
  # Clean tempdir
  on.exit(
    oe_clean(tempdir()),
    add = TRUE,
    after = TRUE
  )

  # See https://github.com/ropensci/osmextract/issues/245
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
    oe_get("Sevastopol", download_only = TRUE, skip_vectortranslate = TRUE, quiet = TRUE, download_directory = tempdir()),
    regexp = "openstreetmap_fr"
  )
})

