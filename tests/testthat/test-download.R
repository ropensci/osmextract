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

test_that("is_valid_pbf: accepts extracts and rejects non-extracts", {
  example = system.file("its-example.osm.pbf", package = "osmextract")
  skip_if(example == "", "the bundled example pbf is not installed")
  expect_true(is_valid_pbf(example))

  # Everything here goes through withr, because setup_pbf() asserts that
  # tempdir() holds no .osm.pbf or .gpkg file, so nothing may be left behind.

  # A provider can answer with 200 and a web page rather than an extract
  html = withr::local_tempfile(fileext = ".osm.pbf")
  writeLines("<!DOCTYPE html>\n<html><body>Not found</body></html>", html)
  expect_false(is_valid_pbf(html))

  # Exists, but far too short to hold a blob header
  expect_false(is_valid_pbf(withr::local_tempfile(fileext = ".pbf")))

  # Does not exist at all
  expect_false(is_valid_pbf(file.path(tempdir(), "no-such-extract.pbf")))
})

test_that("oe_download: reports the age of a cached file", {
  example = system.file("its-example.osm.pbf", package = "osmextract")
  skip_if(example == "", "the bundled example pbf is not installed")

  d = withr::local_tempdir()
  cached = file.path(d, "geofabrik_test-latest.osm.pbf")
  file.copy(example, cached)

  # Backdate it so that it counts as stale
  Sys.setFileTime(cached, Sys.time() - 90 * 86400)

  res = NULL
  expect_message(
    res <- oe_download(
      file_url = "https://download.geofabrik.de/test-latest.osm.pbf",
      download_directory = d,
      quiet = FALSE
    ),
    regexp = "90 days old",
    class = "oe_download_skipDownloading"
  )
  expect_equal(res, normalizePath(cached, winslash = "/", mustWork = FALSE))
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
