test_that("oe_clean removes all files in download_directory", {
  file.copy(
    from = system.file("its-example.osm.pbf", package = "osmextract"),
    to = its_pbf
  )

  oe_clean(tempdir())

  expect_equal(
    object = list.files(tempdir(), "\\.(pbf|gpkg)$", full.names = TRUE),
    expected = character(0)
  )
})
