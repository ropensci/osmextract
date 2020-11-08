test_that("oe_read: simplest examples work", {
  f = system.file("its-example.osm.pbf", package = "osmextract")
  osm_data = oe_read(f)
  # result is sf object:
  expect_s3_class(object = osm_data, class = "sf")
  # linestring geometry is default:
  expect_equal(
    as.character(unique(sf::st_geometry_type(osm_data))),
    "LINESTRING"
  )
  osm_data_points = oe_read(f, layer = "points")
  expect_equal(
    as.character(unique(sf::st_geometry_type(osm_data_points))),
    "POINT"
  )

  f_gpkg = system.file("its-example.gpkg", package = "osmextract")
  if (f_gpkg != "") {
    file.remove(f_gpkg)
  }
})

test_that("or_read: simplest example with a URL works", {
  skip_if_offline()
  my_url = "https://github.com/ITSLeeds/osmextract/raw/master/inst/its-example.osm.pbf"
  expect_error(
    oe_read(
      my_url,
      provider = "test",
      quiet = TRUE,
      download_directory = tempdir()
    ),
    NA
  )
})

test_that("oe_read fails with a clear error message with wrong URL of file path", {
  expect_error(
    oe_read("geofabrik_typo-in-path.osm.pbf"),
    "it doesn't look like a URL"
  )
})

test_that("oe_read fails with misspelled arguments", {
  f = system.file("its-example.osm.pbf", package = "osmextract")
  expect_error(
    oe_read(
      f,
      stringasfactor = FALSE,
    ),
    "no simple features"
  )

  # Remove the .gpkg file from the inst/ directory
  file.remove(oe_read(f, download_only = TRUE))
})
