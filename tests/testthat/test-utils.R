# Prepare the tests
file.copy(
  system.file("its-example.osm.pbf", package = "osmextract"),
  file.path(tempdir(), "its-example.osm.pbf")
)
its_pbf = file.path(tempdir(), "its-example.osm.pbf")

test_that("oe_clean removes all files in download_directory", {
  oe_clean(tempdir())
  expect_equal(
    object = list.files(tempdir(), "\\.(pbf|gpkg)$", full.names = TRUE),
    expected = character(0)
  )
})
