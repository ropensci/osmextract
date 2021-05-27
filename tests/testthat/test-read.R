# Copy its-example.osm.pbf to tempdir(). See also
# https://github.com/ropensci/osmextract/issues/175
file.copy(
  system.file("its-example.osm.pbf", package = "osmextract"),
  file.path(tempdir(), "its-example.osm.pbf")
)
its_pbf = file.path(tempdir(), "its-example.osm.pbf")

test_that("oe_read: simplest examples work", {
  # Read in data
  osm_data = oe_read(its_pbf, quiet = TRUE)

  # Run the tests. Check that result is sf object:
  expect_s3_class(object = osm_data, class = "sf")
  # Linestring geometry is default:
  expect_equal(
    as.character(unique(sf::st_geometry_type(osm_data))),
    "LINESTRING"
  )

  # Read-in points
  osm_data_points = oe_read(its_pbf, layer = "points", quiet = TRUE)
  expect_equal(
    as.character(unique(sf::st_geometry_type(osm_data_points))),
    "POINT"
  )

  # Remove its-example from tempdir()
  file.remove(list.files(tempdir(), pattern = "its-example.gpkg", full.names = TRUE))
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

# Refill tempdir
file.copy(
  system.file("its-example.osm.pbf", package = "osmextract"),
  file.path(tempdir(), "its-example.osm.pbf")
)
its_pbf = file.path(tempdir(), "its-example.osm.pbf")

test_that("oe_read fails with a clear error message with wrong URL of file path", {
  expect_error(
    oe_read("geofabrik_typo-in-path.osm.pbf"),
    "The input file_path does not correspond to any existing file and it doesn't look like a URL."
  )
})

test_that("oe_read fails with misspelled arguments", {
  # Run tests
  expect_error(
    suppressWarnings(oe_read(
      its_pbf,
      stringasfactor = FALSE,
      quiet = TRUE
    )),
    "no simple features"
  )

  # Remove the .gpkg file from the inst/ directory
  file.remove(list.files(tempdir(), pattern = "its-example.gpkg", full.names = TRUE))
})

test_that("oe_read returns a warning message when query != layer", {
  # Run tests
  expect_warning(
    object = oe_read(
      its_pbf,
      layer = "points",
      query = "SELECT * FROM lines",
      quiet = TRUE
    ),
    regexp = "The query selected a layer which is different from layer argument."
  )

  # Remove the files
  file.remove(list.files(tempdir(), pattern = "its-example.gpkg", full.names = TRUE))
})

test_that("extra_tags are not ignored when vectortranslate_options is not NULL", {
  its_gpkg = oe_read(
    its_pbf,
    quiet = TRUE,
    vectortranslate_options = c("-limit", 5L),
    extra_tags = c("oneway")
  )

  expect_true("oneway" %in% colnames(its_gpkg))

  # clean tempdir
  file.remove(list.files(tempdir(), pattern = "its-example.gpkg", full.names = TRUE))
})

test_that("osmconf_ini is not ignored when vectortranslate_options is not NULL", {
  # Create a fake osmconf_ini
  custom_osmconf_ini = readLines(system.file("osmconf.ini", package = "osmextract"))
  custom_osmconf_ini[[18]] = "report_all_nodes=yes"
  custom_osmconf_ini[[21]] = "report_all_ways=yes"
  temp_ini = tempfile(fileext = ".ini")
  writeLines(custom_osmconf_ini, temp_ini)

  # Regular output
  its_gpkg = oe_read(its_pbf, quiet = TRUE)
  # Ad hoc osmconf_ini + vectortranslate options
  its_gpkg_osmconf = oe_read(
    its_pbf,
    quiet = TRUE,
    osmconf_ini = temp_ini,
    vectortranslate_options = c("-t_srs", "EPSG:27700")
  )

  # Tests
  expect_gte(nrow(its_gpkg_osmconf), nrow(its_gpkg))
  expect_true(sf::st_is_longlat(its_gpkg))
  expect_false(sf::st_is_longlat(its_gpkg_osmconf))

  # Warning with adhoc osmconf_ini + extra_tags
  expect_warning(
    oe_read(
      its_pbf,
      quiet = TRUE,
      osmconf_ini = temp_ini,
      vectortranslate_options = c("-t_srs", "EPSG:27700"),
      extra_tags = "oneway"
    )
  )

  # Warning with ad-hoc osmconf_ini + CONFIG_FILE in vectortranslate_options
  expect_warning(
    oe_read(
      its_pbf,
      quiet = TRUE,
      osmconf_ini = temp_ini,
      vectortranslate_options = c("-t_srs", "EPSG:27700", "-oo", paste0("CONFIG_FILE=", temp_ini)),
    )
  )

  # clean tempdir
  file.remove(list.files(tempdir(), pattern = "its-example.gpkg", full.names = TRUE))
})
