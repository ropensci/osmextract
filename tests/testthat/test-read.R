test_that("oe_read: simplest examples work", {
  # Copy its-example.osm.pbf to tempdir(). See also
  # https://github.com/ropensci/osmextract/issues/175
  file.copy(
    system.file("its-example.osm.pbf", package = "osmextract"),
    file.path(tempdir(), "its-example.osm.pbf")
  )
  f = file.path(tempdir(), "its-example.osm.pbf")

  # Read in data
  osm_data = oe_read(f, quiet = TRUE)

  # Run the tests. Check that result is sf object:
  expect_s3_class(object = osm_data, class = "sf")
  # Linestring geometry is default:
  expect_equal(
    as.character(unique(sf::st_geometry_type(osm_data))),
    "LINESTRING"
  )

  # Read-in points
  osm_data_points = oe_read(f, layer = "points", quiet = TRUE)
  expect_equal(
    as.character(unique(sf::st_geometry_type(osm_data_points))),
    "POINT"
  )

  # Remove its-example from tempdir()
  file.remove(list.files(tempdir(), pattern = "its-example", full.names = TRUE))
})

test_that("or_read: simplest example with a URL works", {
  skip_on_cran()
  skip_if_offline()

  my_url = "https://github.com/ropensci/osmextract/raw/master/inst/its-example.osm.pbf"
  expect_error(
    oe_read(
      my_url,
      provider = "test",
      quiet = TRUE,
      download_directory = tempdir()
    ),
    NA
  )

  # Clean tempdir
  file.remove(list.files(tempdir(), pattern = "its-example", full.names = TRUE))
})

test_that("oe_read fails with a clear error message with wrong URL of file path", {
  expect_error(
    oe_read("geofabrik_typo-in-path.osm.pbf"),
    "The input file_path does not correspond to any existing file and it doesn't look like a URL."
  )
})

test_that("oe_read fails with misspelled arguments", {
  # Copy its-example.osm.pbf to tempdir(). See also
  # https://github.com/ropensci/osmextract/issues/175
  file.copy(
    system.file("its-example.osm.pbf", package = "osmextract"),
    file.path(tempdir(), "its-example.osm.pbf")
  )
  f = file.path(tempdir(), "its-example.osm.pbf")

  # Run tests
  expect_error(
    suppressWarnings(oe_read(
      f,
      stringasfactor = FALSE,
      quiet = TRUE
    )),
    "no simple features"
  )

  # Remove the .gpkg file from the inst/ directory
  file.remove(list.files(tempdir(), pattern = "its-example", full.names = TRUE))
})

test_that("oe_read returns a warning message when query != layer", {
  # Fill tempdir
  file.copy(
    system.file("its-example.osm.pbf", package = "osmextract"),
    file.path(tempdir(), "its-example.osm.pbf")
  )
  f = file.path(tempdir(), "its-example.osm.pbf")

  # Run tests
  expect_warning(
    object = oe_read(
      f,
      layer = "points",
      query = "SELECT * FROM lines",
      quiet = TRUE
    ),
    regexp = "The query selected a layer which is different from layer argument."
  )


  # Remove the files
  file.remove(list.files(tempdir(), pattern = "its-example", full.names = TRUE))
})
