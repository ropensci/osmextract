# Prepare the tests
file.copy(
  system.file("its-example.osm.pbf", package = "osmextract"),
  file.path(tempdir(), "its-example.osm.pbf")
)
its_pbf = file.path(tempdir(), "its-example.osm.pbf")

test_that("get_keys: simplest examples work", {
  expect_equal(get_keys('"A"=>"B"'), "A")
  expect_equal(get_keys(c('"A"=>"B"', '"C"=>"D"')), c("A", "C"))
})

test_that("get_keys: more complicated examples: ", {
  expect_equal(get_keys('"A"=>"B=C"'), "A")
  expect_equal(get_keys('"A"=>"B,C"'), "A")
  expect_equal(get_keys('"A"=>"B\\""'), "A")
  expect_equal(get_keys('"A"=>"B > C'), "A")
})

test_that("oe_get_keys: simplest examples work", {
  # Define path to gpkg object
  its_gpkg = oe_vectortranslate(its_pbf, quiet = TRUE)

  # Extract keys from pbg and gpkg file
  keys1 = oe_get_keys(its_pbf)
  keys2 = oe_get_keys(its_gpkg)

  # Tests
  expect_type(keys1, "character")
  expect_type(keys2, "character")
  expect_equal(length(keys1), length(keys2))

  file.remove(its_gpkg)
})

test_that("oe_get_keys: returns error with wrong inputs", {
  expect_error(oe_get_keys("xxx.gpkg")) # file does not exist
})

test_that("oe_get_keys stops when there is no other_tags field", {
  # Read data ignoring the other_tags field
  its_object = oe_read(
    its_pbf,
    download_directory = tempdir(),
    query = "SELECT highway, geometry FROM lines",
    quiet = TRUE
  )
  expect_error(
    oe_get_keys(its_object),
    "The input object must have an other_tags field."
  )

  # Translate data ignoring the other_tags field
  its_path = oe_read(
    its_pbf,
    download_only = TRUE,
    download_directory = tempdir(),
    quiet = TRUE,
    vectortranslate_options = c(
      "-f", "GPKG", "-overwrite", "-select", "highway", "lines"
    )
  )
  expect_error(
    oe_get_keys(its_path),
    "The input file must have an other_tags field."
  )

  # Clean tempdir
  file.remove(its_path)
})

# Clean tempdir
file.remove(list.files(tempdir(), pattern = "its-example", full.names = TRUE))
