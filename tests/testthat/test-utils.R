test_that("oe_clean removes all files in download_directory", {
  withr::defer(oe_clean(tempdir()))

  file.copy(
    from = system.file("its-example.osm.pbf", package = "osmextract"),
    to = file.path(tempdir(), "test_its-example.osm.pbf")
  )

  oe_clean(tempdir())

  expect_equal(
    object = list.files(tempdir(), "\\.(pbf|gpkg)$", full.names = TRUE),
    expected = character(0)
  )
})
