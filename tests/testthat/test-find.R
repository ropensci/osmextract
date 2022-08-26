test_that("oe_find: simplest example works", {
  withr::local_envvar(
    .new = list(
      "OSMEXT_DOWNLOAD_DIRECTORY" = tempdir(),
      "TESTTHAT" = "true"
    )
  )
  its_pbf = setup_pbf()

  oe_vectortranslate(
    file_path = its_pbf,
    quiet = TRUE
  )

  its_leeds_find = oe_find(
    "ITS Leeds",
    quiet = TRUE
  )
  expect_type(its_leeds_find, "character")
  expect_length(its_leeds_find, 2)
})

test_that("oe_find: return_gpkg and return_pbf arguments work", {
  withr::local_envvar(
    .new = list(
      "OSMEXT_DOWNLOAD_DIRECTORY" = tempdir(),
      "TESTTHAT" = "true"
    )
  )
  its_pbf = setup_pbf()

  oe_vectortranslate(
    file_path = its_pbf,
    quiet = TRUE
  )

  pbf_find = oe_find(
    "ITS Leeds",
    quiet = TRUE,
    return_gpkg = FALSE
  )
  gpkg_find = oe_find(
    "ITS Leeds",
    quiet = TRUE,
    return_pbf = FALSE
  )

  expect_length(pbf_find, 1)
  expect_length(gpkg_find, 1)

  expect_type(pbf_find, "character")
  expect_type(gpkg_find, "character")

  expect_match(pbf_find, "pbf")
  expect_match(gpkg_find, "gpkg")
})

test_that("download_if_missing in oe_find works", {
  skip_on_cran()
  skip_if_offline("github.com")
  withr::local_envvar(
    .new = list(
      "OSMEXT_DOWNLOAD_DIRECTORY" = tempdir(),
      "TESTTHAT" = "true"
    )
  )
  withr::defer(oe_clean(tempdir()))

  # Test that tempdir is really empty
  expect_true(!file.exists(file.path(tempdir(), "test_its-example.osm.pbf")))

  # Test download_if_missing
  its_leeds_find = oe_find(
    "ITS Leeds",
    provider = "test",
    download_if_missing = TRUE,
    quiet = TRUE
  )
  expect_type(its_leeds_find, "character")
  expect_length(its_leeds_find, 2)
})
