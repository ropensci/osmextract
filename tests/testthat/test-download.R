test_that("oe_download: simplest examples work", {
  skip_if_offline()
  its_match = oe_match("ITS Leeds", provider = "test")
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

  # clean tempdir
  file.remove(
    oe_get(
      "ITS Leeds",
      download_only = TRUE,
      download_directory = tempdir(),
      skip_vectortranslate = TRUE,
      quiet = TRUE
    )
  )
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

