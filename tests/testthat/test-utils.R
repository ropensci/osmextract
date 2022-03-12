# Prepare the tests
file.copy(
  system.file("its-example.osm.pbf", package = "osmextract"),
  file.path(tempdir(), "its-example.osm.pbf")
)
its_pbf = file.path(tempdir(), "its-example.osm.pbf")

test_that("oe_clean removes all files in download_directory", {
  old_dd = Sys.getenv("OSMEXT_DOWNLOAD_DIRECTORY", tempdir())
  Sys.setenv(OSMEXT_DOWNLOAD_DIRECTORY = tempdir())

  oe_clean()
  expect_equal(
    object = list.files(tempdir(), "\\.(pbf|gpkg)$", full.names = TRUE),
    expected = character(0)
  )

  Sys.setenv(OSMEXT_DOWNLOAD_DIRECTORY = old_dd)
})

file.remove(list.files(tempdir(), "\\.(pbf|gpkg)$", full.names = TRUE))
