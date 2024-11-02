test_that("oe_get_network: simplest examples work", {
  withr::local_envvar(
    .new = list(
      "OSMEXT_DOWNLOAD_DIRECTORY" = tempdir(),
      "TESTTHAT" = "true"
    )
  )
  its_pbf = setup_pbf()

  expect_error(oe_get_network("ITS Leeds", quiet = TRUE), NA)
})

test_that("oe_get_network: -where clause has the same behaviour as the corresponding R code", {
  # See the discussion in #298 for more details about this test. The basic idea
  # is to test that the output of SQL code is the same as analogous R
  # expressions run on the same .osm.pbf file.
  withr::local_envvar(
    .new = list(
      "OSMEXT_DOWNLOAD_DIRECTORY" = tempdir(),
      "TESTTHAT" = "true"
    )
  )
  its_pbf <- setup_pbf()

  its <- oe_read(its_pbf,
    layer = "lines",
    extra_tags = c("access", "service", "oneway"), quiet = TRUE
  )
  # Replicate the SQL conditions for driving mode using regular R code
  idx_R <- with(
    its,
    !is.na(highway) &
    # NB: %in% automatically sets NA %in% ('bar') as FALSE
    (is.na(highway) | highway %!in% c(
      'abandoned', 'bus_guideway', 'byway', 'construction', 'corridor', 'elevator',
      'fixme', 'escalator', 'gallop', 'historic', 'no', 'planned', 'platform',
      'proposed', 'cycleway', 'pedestrian', 'bridleway', 'path', 'footway',
      'steps'
    )) &
    (is.na(access) | access %!in% c('private', 'no')) &
    (is.na(service) | !grepl('^private', service, ignore.case = TRUE))
  )

  its_driving <- oe_get_network("ITS Leeds", mode = "driving", quiet = TRUE)
  expect_true(nrow(its_driving) == sum(idx_R))
})

test_that("oe_get_network: options in ... work correctly", {
  withr::local_envvar(
    .new = list(
      "OSMEXT_DOWNLOAD_DIRECTORY" = tempdir(),
      "TESTTHAT" = "true"
    )
  )
  its_pbf = setup_pbf()

  expect_warning(oe_get_network("ITS Leeds", layer = "points", quiet = TRUE))
  expect_message(oe_get_network("ITS Leeds", quiet = TRUE), NA)

  driving_network_with_area_tag = oe_get_network(
    "ITS Leeds",
    mode = "driving",
    extra_tags = "area",
    quiet = TRUE
  )
  expect_true("area" %in% colnames(driving_network_with_area_tag))

  # Cannot use -where arg
  expect_error(
    object = oe_get_network(
      place = "ITS Leeds",
      quiet = TRUE,
      vectortranslate_options = c("-where", "ABC")
    ),
    class = "oe_get_network-cannotUseWhere"
  )

  walking_network_27700 = oe_get_network(
    "ITS Leeds",
    mode = "walking",
    vectortranslate_options = c("-t_srs", "EPSG:27700"),
    quiet = TRUE
  )
  expect_true(sf::st_crs(walking_network_27700) == sf::st_crs("EPSG:27700"))
})
