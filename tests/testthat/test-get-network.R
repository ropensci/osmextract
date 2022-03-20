# Prepare the tests
file.copy(
  system.file("its-example.osm.pbf", package = "osmextract"),
  file.path(tempdir(), "its-example.osm.pbf")
)

test_that("oe_get_network: simplest examples work", {
  expect_error(oe_get_network("ITS Leeds", quiet = TRUE, download_directory = tempdir()), NA)
})

test_that("oe_get_network: options in ... work correctly", {
  # Clean tempdir
  on.exit(
    oe_clean(tempdir()),
    add = TRUE,
    after = TRUE
  )

  expect_warning(oe_get_network("ITS Leeds", layer = "points", quiet = TRUE, download_directory = tempdir()))
  expect_message(oe_get_network("ITS Leeds", quiet = TRUE, download_directory = tempdir()), NA)

  driving_network_with_area_tag = oe_get_network(
    "ITS Leeds",
    mode = "driving",
    extra_tags = "area",
    quiet = TRUE,
    download_directory = tempdir()
  )
  expect_true("area" %in% colnames(driving_network_with_area_tag))

  expect_error(oe_get_network(
    place = "ITS Leeds",
    quiet = TRUE,
    vectortranslate_options = c("-where", "ABC"),
    download_directory = tempdir()
  ))

  walking_network_27700 = oe_get_network(
    "ITS Leeds",
    mode = "walking",
    vectortranslate_options = c("-t_srs", "EPSG:27700"),
    quiet = TRUE,
    download_directory = tempdir()
  )
  expect_true(sf::st_crs(walking_network_27700) == sf::st_crs(27700))
})
