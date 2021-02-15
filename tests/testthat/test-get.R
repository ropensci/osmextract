test_that("oe_get: simplest examples work", {
  expect_s3_class(
    oe_get("ITS Leeds", provider = "test", quiet = TRUE, download_directory = tempdir()),
    "sf"
  )
  # clean tempdir
  file.remove(oe_find("ITS Leeds", provider = "test", download_directory = tempdir()))
})

test_that("vectortranslate is not skipped if force_download is TRUE", {
  # See https://github.com/ropensci/osmextract/issues/144
  # I need to download the following files in a new directory since they could
  # be mixed with previously downloaded files (and hence ruin the tests)

  small_its_leeds <- oe_get(
    "ITS Leeds",
    download_directory = tempdir(),
    vectortranslate_options = c(
    "-f", "GPKG",
    "-overwrite",
    "-lco", "GEOMETRY_NAME=geometry",
    "-where", "highway IN ('service')",
    "lines"
    ),
    quiet = TRUE
  )

  # Download it again
  its_leeds <- oe_get(
    "ITS Leeds",
    download_directory = tempdir(),
    force_vectortranslate = TRUE,
    quiet = TRUE
  )

  expect_gte(nrow(its_leeds), nrow(small_its_leeds))

  # clean tempdir
  file.remove(oe_find("ITS Leeds", provider = "test", download_directory = tempdir()))
})

test_that("We can specify path using ~", {
  # I think that we cannot safely add a directory on CRAN tests
  # See also https://github.com/ropensci/osmextract/issues/175
  skip_on_cran()
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
