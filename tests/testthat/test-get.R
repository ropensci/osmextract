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
