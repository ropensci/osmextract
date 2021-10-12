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

test_that("oe_vectortranslate returns file_path when .gpkg exists", {
  its_gpkg = oe_vectortranslate(its_pbf, quiet = TRUE)
  expect_message(
    oe_vectortranslate(its_pbf),
    "Skip vectortranslate operations."
  )
  file.remove(its_gpkg)
})

test_that("oe_vectortranslate succesfully adds new tags", {
  # Check all layers, ref https://github.com/ropensci/osmextract/issues/229
  # Check points:
  its_gpkg = oe_vectortranslate(
    its_pbf,
    layer = "points",
    extra_tags = "crossing",
    force_vectortranslate = TRUE,
    quiet = TRUE
  )
  expect_match(
    paste(names(sf::st_read(its_gpkg, "points", quiet = TRUE)), collapse = "-"),
    "crossing"
  )
  # Check lines:
  its_gpkg = oe_vectortranslate(
    its_pbf,
    layer = "lines",
    extra_tags = "oneway",
    force_vectortranslate = TRUE,
    quiet = TRUE
  )
  expect_match(
    paste(names(sf::st_read(its_gpkg, "lines", quiet = TRUE)), collapse = "-"),
    "oneway"
  )
  # Check multilinestrings :
  its_gpkg = oe_vectortranslate(
    its_pbf,
    layer = "multilinestrings",
    extra_tags = "operator",
    force_vectortranslate = TRUE,
    quiet = TRUE
  )
  expect_match(
    paste(names(sf::st_read(its_gpkg, "multilinestrings", quiet = TRUE)), collapse = "-"),
    "operator"
  )
  # Check multipolygons:
  its_gpkg = oe_vectortranslate(
    its_pbf,
    layer = "multipolygons",
    extra_tags = "foot",
    force_vectortranslate = TRUE,
    quiet = TRUE
  )
  expect_match(
    paste(names(sf::st_read(its_gpkg, "multipolygons", quiet = TRUE)), collapse = "-"),
    "foot"
  )
  # Check other_relations:
  its_gpkg = oe_vectortranslate(
    its_pbf,
    layer = "other_relations",
    extra_tags = "site",
    force_vectortranslate = TRUE,
    quiet = TRUE
  )
  expect_match(
    paste(names(sf::st_read(its_gpkg, "other_relations", quiet = TRUE)), collapse = "-"),
    "site"
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

test_that("oe_vectortranslate returns no warning with duplicated field in extra_tags", {
  # The idea is that the user may request one or more fields that are already
  # included in the default ones. In that case, GDAL returns a message like:
  # GDAL Message 1: Field 'natural' already exists. Renaming it as 'natural2'.
  # After the following discussion
  # https://github.com/ropensci/osmextract/issues/229#issuecomment-941002791 I
  # included a call to unique to filter the duplicated fields.
  expect_warning(
    object = {
    its_gpkg = oe_vectortranslate(its_pbf, quiet = TRUE, extra_tags = c("highway", "barrier", "oneway"))
    },
    regexp = NA
  )
  file.remove(its_gpkg) # which points to the same file as its_gpkg
})

test_that("vectortranslate_options are autocompleted", {
  expect_error(
    oe_vectortranslate(
      its_pbf,
      quiet = TRUE,
      vectortranslate_options = c("-t_srs", "EPSG:27700")
    ),
    NA
  )

  # clean tempdir
  file.remove(list.files(tempdir(), pattern = "its-example.gpkg", full.names = TRUE))
})

test_that("vectortranslate is not skipped if force_download is TRUE", {
  # See https://github.com/ropensci/osmextract/issues/144
  # I need to download the following files in a new directory since they could
  # be mixed with previously downloaded files (and hence ruin the tests)
  small_its_leeds = oe_read(
    its_pbf,
    download_directory = tempdir(),
    vectortranslate_options = c(
      # the other options should be filled automatically
      "-where", "highway IN ('service')"
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
