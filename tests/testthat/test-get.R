test_that("oe_get: simplest examples work", {
  # since it requires internet connection
  skip_on_cran()
  skip_if_offline("github.com")

  expect_s3_class(
    oe_get("ITS Leeds", provider = "test", quiet = TRUE, download_directory = tempdir()),
    "sf"
  )
  # clean tempdir
  file.remove(list.files(tempdir(), pattern = "its-example", full.names = TRUE))
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
  # See https://github.com/ropensci/osmextract/issues/245
  skip_on_cran()
  skip_if_offline("download.openstreetmap.fr")

  # I should also check the status code of the provider
  my_status <- httr::status_code(httr::GET("https://download.openstreetmap.fr/"))
  skip_if_not(my_status == 200L)

  expect_match(
    oe_get("Sevastopol", download_only = TRUE, skip_vectortranslate = TRUE, quiet = TRUE, download_directory = tempdir()),
    regexp = "openstreetmap_fr"
  )
  file.remove(list.files(tempdir(), pattern = "pbf", full.names = TRUE))
})

