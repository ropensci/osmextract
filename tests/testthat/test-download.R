test_that("oe_download: simplest examples work", {
  skip_if_offline()
  its_match = oe_match("ITS Leeds", provider = "test")
  expect_error(
    oe_download(
      file_url = its_match$url,
      provider = "test",
      download_directory = tempdir(),
      quiet = FALSE
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
})

test_that("oe_download: fails with more than one URL", {
  expect_error(oe_download(c("a", "b")))
})

test_that("infer_provider_from_url works: ", {
  expect_error(
    infer_provider_from_url("https://github.com/ITSLeeds/osmextract"),
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

