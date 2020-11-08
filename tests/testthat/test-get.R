test_that("oe_get: simplest examples work", {
  expect_s3_class(oe_get("ITS Leeds", provider = "test"), "sf")
})

test_that("vectortranslate is not skipped if force_download is TRUE", {
  # See https://github.com/ITSLeeds/osmextract/issues/144
  # I need to download the following files in a new directory since they could
  # be mixed with previously downloaded files (and hence ruin the tests)
  my_tempdir = tempdir()

  small_its_leeds <- oe_get(
    "ITS Leeds",
    download_directory = my_tempdir,
    vectortranslate_options = c(
    "-f", "GPKG",
    "-overwrite",
    "-lco", "GEOMETRY_NAME=geometry",
    "-where", "highway IN ('service')",
    "lines"
  ))

  # Download it again
  its_leeds <- oe_get(
    "ITS Leeds",
    download_directory = my_tempdir,
    force_vectortranslate = TRUE,
  )

  expect_gte(nrow(its_leeds), nrow(small_its_leeds))
})
