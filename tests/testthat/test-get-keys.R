################################################################################
# NB: ALWAYS REMEMBER TO SET                                                   #
# withr::local_envvar(                                                         #
#   .new = list("OSMEXT_DOWNLOAD_DIRECTORY" = tempdir())                       #
# )                                                                            #
# IF YOU NEED TO MODIFY THE OSMEXT_DOWNLOAD_DIRECTORY envvar INSIDE THE TESTS. #
#                                                                              #
# I could also set the same option at the beginning of the script but that     #
# makes the debugging more difficult since I have to manually reset the        #
# options at the end of the debugging process.                                 #
#                                                                              #
# See R/test-helpers.R for more details                                        #
#                                                                              #
################################################################################

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
  expect_identical(
    object = unclass(get_keys('"A"=>"B"', values = TRUE)),
    expected = list(A = "B"),
    ignore_attr = TRUE
  )
  expect_identical(
    object = unclass(get_keys('"A"=>"B","C"=>"D"', values = TRUE)),
    expected = list(A = "B", C = "D"),
    ignore_attr = TRUE
  )
})

test_that("get_keys (values): more complicated examples", {
  # = and , into the values
  expect_identical(
    object = unclass(get_keys('"A"=>"B=C","C"=>"D,E"', values = TRUE)),
    expected = list(A = "B=C", C = "D,E"),
    ignore_attr = TRUE
  )
  # Multiple outputs + sorted keys
  expect_identical(
    object = unclass(get_keys(c('"A"=>"B","C"=>"D"', '"C"=>"E"'), values = TRUE)),
    expected = list(C = c("D", "E"), A = "B"),
    ignore_attr = TRUE
  )

  # subset keys
  expect_identical(
    object = unclass(get_keys(c('"A"=>"B","C"=>"D"', '"C"=>"E"'), values = TRUE, which_keys = "C")),
    expected = list(C = c("D", "E")),
    ignore_attr = TRUE
  )

  # there might be empty values or newlines, see
  # https://github.com/ropensci/osmextract/issues/250
  expect_identical(
    object = unclass(get_keys('"A"=>"\n","B"=>"C","D"=>""', values = TRUE)),
    expected = list(A = "", B = "C", D = ""),
    ignore_attr = TRUE
  )
})

test_that("oe_get_keys: simplest examples work", {
  its_pbf = setup_pbf()
  withr::local_envvar(
    .new = list("OSMEXT_DOWNLOAD_DIRECTORY" = tempdir())
  )

  # Define path to gpkg object
  its_gpkg = oe_vectortranslate(its_pbf, quiet = TRUE)

  # Extract keys from pbg and gpkg file
  keys1 = oe_get_keys(its_pbf)
  keys2 = oe_get_keys(its_gpkg)

  # Tests
  expect_type(keys1, "character")
  expect_type(keys2, "character")
  expect_equal(length(keys1), length(keys2))
})

test_that("oe_get_keys + values: printing method", {
  its_pbf = setup_pbf()
  withr::local_envvar(
    .new = list("OSMEXT_DOWNLOAD_DIRECTORY" = tempdir())
  )

  expect_snapshot_output(oe_get_keys(its_pbf, values = TRUE))

  # Define path to gpkg object
  its_gpkg = oe_vectortranslate(its_pbf, quiet = TRUE)
  expect_snapshot_output(oe_get_keys(its_gpkg, values = TRUE))
})

test_that("oe_get_keys: returns error with wrong inputs", {
  expect_error(
    oe_get_keys(sf::st_sfc(sf::st_point(c(1, 1)), crs = 4326)),
    class = "osmext-oe_get_keys-no_support"
  )
  expect_error( # file does not exist
    oe_get_keys("xxx.gpkg"),
    class = "osmext-oe_get_keys-matched_input_missing"
  )
  expect_error( # length > 1
    oe_get_keys(c("a.gpkg", "b.gpkg")),
    class = "osmext-oe_get_keys-length_1_input"
  )
})

test_that("oe_get_keys: reads from sf object", {
  its_pbf = setup_pbf()
  withr::local_envvar(
    .new = list("OSMEXT_DOWNLOAD_DIRECTORY" = tempdir())
  )

  its = oe_read(its_pbf, skip_vectortranslate = TRUE, quiet = TRUE)
  expect_error(oe_get_keys(its), NA)
})

test_that("the output from oe_get_keys is the same as for hstore_get_values", {
  its_pbf = setup_pbf()
  withr::local_envvar(
    .new = list("OSMEXT_DOWNLOAD_DIRECTORY" = tempdir())
  )

  my_output = oe_get_keys("ITS Leeds", values = TRUE)
  its_leeds_with_surface = oe_get(
    "ITS Leeds",
    query = "SELECT *, hstore_get_value(other_tags, 'surface') AS surface FROM lines",
    quiet = TRUE,
    force_vectortranslate = TRUE
  )

  expect_equal(
    object = sort(table(my_output[["surface"]]), decreasing = TRUE)[1:2],
    expected = sort(table(its_leeds_with_surface[["surface"]]), decreasing = TRUE)[1:2]
  )
})

test_that("oe_get_keys stops when there is no other_tags field", {
  its_pbf = setup_pbf()
  withr::local_envvar(
    .new = list("OSMEXT_DOWNLOAD_DIRECTORY" = tempdir())
  )

  # Read data ignoring the other_tags field
  its_object = oe_read(
    its_pbf,
    query = "SELECT highway, geometry FROM lines",
    quiet = TRUE
  )
  expect_error(
    oe_get_keys(its_object),
    "The input object must have an other_tags field."
  )

  # Translate data ignoring the other_tags field
  its_gpkg = oe_read(
    its_pbf,
    download_only = TRUE,
    quiet = TRUE,
    vectortranslate_options = c(
      "-f", "GPKG", "-overwrite", "-select", "highway", "lines"
    )
  )
  expect_error(
    oe_get_keys(its_gpkg),
    "The input file must have an other_tags field."
  )
})

test_that("oe_get_keys matches input zone with file", {
  its_pbf = setup_pbf()
  withr::local_envvar(
    .new = list("OSMEXT_DOWNLOAD_DIRECTORY" = tempdir())
  )

  # Simplest example works
  expect_error(oe_get_keys("ITS Leeds"), NA)

  # Cannot extract from files that were not previously downloaded
  expect_error(oe_get_keys("Brazil"))
})

test_that("oe_get_keys errors when asking for non existing layer", {
  its_pbf = setup_pbf()
  withr::local_envvar(
    .new = list("OSMEXT_DOWNLOAD_DIRECTORY" = tempdir())
  )
  its_gpkg = oe_vectortranslate(its_pbf, quiet = TRUE)

  expect_error(
    object = oe_get_keys(its_gpkg, layer = "points"),
    class = "osmext-oe_get_keys-missing_selected_layer"
  )
})

test_that("oe_get_keys emits warning when some keys were already extracted", {
  its_pbf = setup_pbf()
  withr::local_envvar(
    .new = list("OSMEXT_DOWNLOAD_DIRECTORY" = tempdir())
  )
  its_gpkg = oe_vectortranslate(its_pbf, quiet = TRUE, extra_tags = "amenity")

  expect_warning(
    object = oe_get_keys(its_gpkg),
    regexp = "The following keys were already extracted"
  )
})
