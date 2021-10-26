test_that("oe_download: simplest examples work", {
  # Skip tests that require internet connection
  skip_on_cran()
  skip_if_offline("github.com")

  # Run tests
  its_match = oe_match("ITS Leeds", provider = "test", quiet = TRUE)
  expect_error(
    oe_download(
      file_url = its_match$url,
      provider = "test",
      download_directory = tempdir(),
      quiet = TRUE
    ),
    NA
  )

  expect_message(
    oe_download(
      file_url = its_match$url,
      provider = "test",
      download_directory = tempdir(),
      quiet = FALSE
    ),
    "Skip downloading."
  )

  # Clean tempdir
  file.remove(list.files(tempdir(), pattern = "its-example", full.names = TRUE))
})

test_that("oe_download: fails with more than one URL", {
  expect_error(oe_download(c("a", "b")))
})

test_that("infer_provider_from_url works: ", {
  expect_error(
    infer_provider_from_url("https://github.com/ropensci/osmextract"),
    "Cannot infer the provider from the url, please specify it."
  )
  expect_match(
    infer_provider_from_url("https://download.geofabrik.de/africa-latest.osm.pbf"),
    "geofabrik"
  )
  expect_match(
    infer_provider_from_url("https://download.bbbike.org/osm/bbbike/Aachen/Aachen.osm.pbf"),
    "bbbike"
  )
})
