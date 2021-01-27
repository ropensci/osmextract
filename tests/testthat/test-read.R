test_that("oe_read: simplest examples work", {
  f = system.file("its-example.osm.pbf", package = "osmextract")
  osm_data = oe_read(f, quiet = TRUE)
  # result is sf object:
  expect_s3_class(object = osm_data, class = "sf")
  # linestring geometry is default:
  expect_equal(
    as.character(unique(sf::st_geometry_type(osm_data))),
    "LINESTRING"
  )
  osm_data_points = oe_read(f, layer = "points", quiet = TRUE)
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

  # clean tempdir
  file.remove(
    oe_read(
      my_url,
      download_only = TRUE,
      download_directory = tempdir(),
      provider = "test"
    )
  )
  file.remove(
    oe_read(
      my_url,
      download_only = TRUE,
      download_directory = tempdir(),
      provider = "test",
      skip_vectortranslate = TRUE
    )
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
      quiet = TRUE
    ),
    "no simple features"
  )

  # Remove the .gpkg file from the inst/ directory
  file.remove(oe_read(f, download_only = TRUE))
})

test_that("oe_read returns a warning message when query != layer", {
  expect_warning(
    oe_get(
      "ITS Leeds",
      layer = "points",
      query = "SELECT * FROM 'lines'",
      download_directory = tempdir()
    ),
    "The query selected a layer which is different from layer argument."
  )

  # Remove the .gpkg file
  file.remove(oe_find("ITS Leeds")[1])
})
