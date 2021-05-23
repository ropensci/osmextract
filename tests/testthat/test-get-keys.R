# Prepare the tests
file.copy(
  system.file("its-example.osm.pbf", package = "osmextract"),
  file.path(tempdir(), "its-example.osm.pbf")
)
its_pbf = file.path(tempdir(), "its-example.osm.pbf")

test_that("get_keys (keys): simplest examples work", {
  expect_equal(get_keys('"A"=>"B"'), "A")
  expect_equal(get_keys(c('"A"=>"B"', '"C"=>"D"')), c("A", "C"))
  # multiple input + sorted output
  expect_equal(
    get_keys(c('"C"=>"D", "C"=>"B"', '"C"=>"A","B"=>"A"')),
    c("C", "B")
  )
})

test_that("get_keys (keys): more complicated examples: ", {
  expect_equal(get_keys('"A"=>"B=C"'), "A") # = in values
  expect_equal(get_keys('"A"=>"B,C"'), "A") # , in values
  expect_equal(get_keys('"A"=>"B\\""'), "A") # \\" in values
  expect_equal(get_keys('"A"=>"B > C'), "A") # > in values
  expect_equal(get_keys('"A"=>"B\nC"'), "A") # \n in values
})

test_that("get_keys (values): simplest examples work", {
  expect_identical(unclass(get_keys('"A"=>"B"', values = TRUE)), list(A = "B"))
  expect_identical(unclass(get_keys('"A"=>"B","C"=>"D"', values = TRUE)), list(A = "B", C = "D"))
})

test_that("get_keys (values): more complicated examples", {
  # = and , into the values
  expect_identical(
    object = unclass(get_keys('"A"=>"B=C","C"=>"D,E"', values = TRUE)),
    expected = list(A = "B=C", C = "D,E")
  )
  # Multiple outputs + sorted keys
  expect_identical(
    object = unclass(get_keys(c('"A"=>"B","C"=>"D"', '"C"=>"E"'), values = TRUE)),
    expected = list(C = c("D", "E"), A = "B")
  )
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

test_that("oe_get_keys + values: printing method", {
  expect_snapshot_output(oe_get_keys(its_pbf, values = TRUE))

  # Define path to gpkg object
  its_gpkg = oe_vectortranslate(its_pbf, quiet = TRUE)
  expect_snapshot_output(oe_get_keys(its_gpkg, values = TRUE))

  file.remove(its_gpkg)
})

test_that("oe_get_keys: returns error with wrong inputs", {
  expect_error(
    oe_get_keys(sf::st_sfc(sf::st_point(c(1, 1)), crs = 4326)),
    "there is no support for objects of class"
  )
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
