test_that("oe_download: simplest examples work", {
  skip_on_cran()
  skip_on_ci()
  skip_if_offline("github.com")
  withr::local_envvar(
    .new = list(
      "OSMEXT_DOWNLOAD_DIRECTORY" = tempdir(),
      "TESTTHAT" = "true"
    )
  )
  # I need to add the withr::defer since I don't use setup pbf here
  withr::defer(oe_clean(tempdir()))

  its_match = oe_match("ITS Leeds", quiet = TRUE)
  expect_error(
    oe_download(
      file_url = its_match$url,
      provider = "test",
      quiet = TRUE
    ),
    NA
  )

  expect_message(
    oe_download(
      file_url = its_match$url,
      provider = "test",
      quiet = FALSE
    ),
    class = "oe_download_skipDownloading"
  )
})

test_that("oe_download: fails with more than one URL", {
  expect_error(oe_download(c("a", "b")), class = "oe_download_LengthFileUrlGt2")
})

test_that("ow_download complains about old extracts", {
  skip_on_cran()
  skip_on_ci()
  skip_if_offline("github.com")
  withr::local_envvar(
    .new = list(
      "OSMEXT_DOWNLOAD_DIRECTORY" = tempdir(),
      "TESTTHAT" = "true"
    )
  )
  # I need to add the withr::defer since I don't use setup pbf here
  withr::defer(oe_clean(tempdir()))

  its_match = oe_match("ITS Leeds", quiet = TRUE)
  its_file = oe_download(
    file_url = its_match$url,
    provider = "test",
    quiet = TRUE
  )

  # Fake the time on the object
  Sys.setFileTime(its_file, Sys.time() - 366 * 24 * 60 * 60)
  expect_warning(
    {
      oe_download(
        file_url = its_match$url,
        provider = "test",
        quiet = TRUE
      )
    },
    class = "oe_download_StaleDays"
  )

  # No warning when we are downloading historical extracts from geofabrik
  malta_file <- oe_download(
    "https://download.geofabrik.de/europe/malta-140101.osm.pbf",
    quiet = TRUE
  )

  Sys.setFileTime(malta_file, Sys.time() - 366 * 24 * 60 * 60)
  expect_no_warning(
    object = {
      oe_download(
        "https://download.geofabrik.de/europe/malta-140101.osm.pbf",
        quiet = TRUE
      )
    }
  )
})

test_that("infer_provider_from_url: simplest examples work", {
  expect_error(
    infer_provider_from_url("https://github.com/ropensci/osmextract"),
    class = "oe_download_CannotInferProviderFromUrl"
  )
  expect_equal(
    infer_provider_from_url("https://download.geofabrik.de/africa-latest.osm.pbf"),
    "geofabrik"
  )
  expect_equal(
    infer_provider_from_url("https://download.bbbike.org/osm/bbbike/Aachen/Aachen.osm.pbf"),
    "bbbike"
  )
  expect_equal(
    infer_provider_from_url("http://download.openstreetmap.fr/extracts/africa-latest.osm.pbf"),
    "openstreetmap_fr"
  )
})

test_that("looks_like_version_url works", {
  expect_true(looks_like_version_url("https://download.geofabrik.de/europe/malta-140101.osm.pbf"))
  expect_false(looks_like_version_url("https://download.geofabrik.de/europe/malta-latest.osm.pbf"))
})
