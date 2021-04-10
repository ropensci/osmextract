# Prepare the tests
file.copy(
  system.file("its-example.osm.pbf", package = "osmextract"),
  file.path(tempdir(), "its-example.osm.pbf")
)
its_pbf = file.path(tempdir(), "its-example.osm.pbf")

test_that("oe_vectortranslate: simplest examples work", {
  its_gpkg = oe_vectortranslate(its_pbf, quiet = TRUE)
  expect_equal(tools::file_ext(its_gpkg), "gpkg")
  file.remove(its_gpkg)
})

test_that("oe_vectortranslate returns file_path is .gpkg exists", {
  its_gpkg = oe_vectortranslate(its_pbf, quiet = TRUE)
  expect_message(
    oe_vectortranslate(its_pbf),
    "Skip vectortranslate operations."
  )
  file.remove(its_gpkg)
})

test_that("oe_vectortranslate adds new tags", {
  its_gpkg = oe_vectortranslate(
    its_pbf,
    extra_tags = "oneway",
    force_vectortranslate = TRUE,
    quiet = TRUE
  )
  expect_match(
    paste(names(sf::st_read(its_gpkg, quiet = TRUE)), collapse = "-"),
    "oneway"
  )
  file.remove(its_gpkg)
})

test_that("oe_vectortranslate adds new tags to existing file", {
  its_gpkg = oe_vectortranslate(its_pbf, quiet = TRUE)
  new_its_gpkg = oe_vectortranslate(its_pbf, extra_tags = c("oneway"), quiet = TRUE)
  expect_match(
    paste(names(sf::st_read(new_its_gpkg, quiet = TRUE)), collapse = "-"),
    "oneway"
  )
  file.remove(new_its_gpkg) # which points to the same file as its_gpkg
})

test_that("oe_get_keys: simplest examples works", {
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

test_that("vectortranslate is not skipped if force_download is TRUE", {
  # See https://github.com/ropensci/osmextract/issues/144
  # I need to download the following files in a new directory since they could
  # be mixed with previously downloaded files (and hence ruin the tests)
  small_its_leeds = oe_read(
    its_pbf,
    download_directory = tempdir(),
    vectortranslate_options = c(
      "-f", "GPKG",
      "-overwrite",
      "-lco", "GEOMETRY_NAME=geometry",
      "-where", "highway IN ('service')",
      "lines"
    ),
    quiet = TRUE
  )

  # Download it again
  its_leeds = oe_read(
    its_pbf,
    download_directory = tempdir(),
    force_vectortranslate = TRUE,
    quiet = TRUE
  )

  expect_gte(nrow(its_leeds), nrow(small_its_leeds))

  # clean tempdir
  file.remove(list.files(tempdir(), pattern = "its-example.gpkg", full.names = TRUE))
})

# Clean tempdir
file.remove(list.files(tempdir(), pattern = "its-example", full.names = TRUE))
