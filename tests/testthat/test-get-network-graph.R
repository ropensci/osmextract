test_that("clean_highway strips _link suffix and filters values", {
  toy_net = sf::st_sf(
    highway = c("primary_link", "residential", "trunk_link"),
    oneway = c("yes", NA, "no"),
    junction = c(NA, "roundabout", NA),
    geometry = sf::st_sfc(
      sf::st_linestring(rbind(c(0, 0), c(1, 0))),
      sf::st_linestring(rbind(c(1, 0), c(2, 0))),
      sf::st_linestring(rbind(c(2, 0), c(3, 0))),
      crs = 4326
    )
  )

  filtered_net = clean_highway(
    toy_net,
    highway_filter = c("primary", "residential")
  )

  expect_identical(filtered_net$highway, c("primary", "residential"))
  expect_false(any(grepl("_link", filtered_net$highway, fixed = TRUE)))
  expect_equal(nrow(filtered_net), 2L)
})

test_that("clean_oneway standardises values and reverses -1 geometries", {
  toy_net = sf::st_sf(
    oneway = c(NA, "alternating", "reversible", "-1", "no"),
    junction = c("roundabout", NA, NA, NA, NA),
    geometry = sf::st_sfc(
      sf::st_linestring(rbind(c(0, 0), c(1, 0))),
      sf::st_linestring(rbind(c(1, 0), c(2, 0))),
      sf::st_linestring(rbind(c(2, 0), c(3, 0))),
      sf::st_linestring(rbind(c(3, 0), c(4, 0))),
      sf::st_linestring(rbind(c(4, 0), c(5, 0))),
      crs = 4326
    )
  )

  clean_net = clean_oneway(toy_net)

  expect_identical(clean_net$oneway, c("yes", "no", "no", "yes", "no"))

  reversed_coords = sf::st_coordinates(clean_net$geometry[4])
  expect_identical(
    unname(reversed_coords[, c("X", "Y")]),
    matrix(c(4, 0, 3, 0), ncol = 2, byrow = TRUE)
  )
})

test_that("clean_oneway applies implied oneway only when junction column present", {
  toy_with_junction = sf::st_sf(
    oneway = c(NA, "no"),
    junction = c("roundabout", NA),
    geometry = sf::st_sfc(
      sf::st_linestring(rbind(c(0, 0), c(1, 0))),
      sf::st_linestring(rbind(c(1, 0), c(2, 0))),
      crs = 4326
    )
  )

  toy_without_junction = sf::st_sf(
    oneway = c(NA, "no"),
    geometry = sf::st_sfc(
      sf::st_linestring(rbind(c(0, 0), c(1, 0))),
      sf::st_linestring(rbind(c(1, 0), c(2, 0))),
      crs = 4326
    )
  )

  expect_message(
    out_with <- clean_oneway(toy_with_junction, quiet = FALSE),
    class = "clean_oneway_implied"
  )
  out_without = clean_oneway(toy_without_junction, quiet = TRUE)

  expect_identical(out_with$oneway, c("yes", "no"))
  expect_identical(out_without$oneway, c("no", "no"))
})

test_that("oe_get_network cleans the highway and oneway values of the sample network", {
  withr::local_envvar(
    .new = list(
      "OSMEXT_DOWNLOAD_DIRECTORY" = tempdir(),
      "TESTTHAT" = "true"
    )
  )
  its_pbf = setup_pbf()

  cleannet = oe_get_network(
    "ITS Leeds",
    mode = "driving",
    quiet = TRUE,
    clean_output = TRUE
  )

  expect_s3_class(cleannet, "sf")
  expect_true(all(c("highway", "oneway", "junction") %in% names(cleannet)))
  expect_false(any(grepl("_link", cleannet$highway, fixed = TRUE)))
  expect_true(all(cleannet$oneway %in% c("yes", "no")))
})

test_that("oe_get_network validates clean_output", {
  withr::local_envvar(
    .new = list(
      "OSMEXT_DOWNLOAD_DIRECTORY" = tempdir(),
      "TESTTHAT" = "true"
    )
  )
  its_pbf = setup_pbf()

  expect_error(
    oe_get_network(
      "ITS Leeds",
      mode = "driving",
      clean_output = "yes",
      quiet = TRUE
    ),
    "logical value"
  )
})

test_that("oe_get_sfnetwork returns an sfnetwork and validates directed", {
  skip_if_not_installed("sfnetworks")
  withr::local_envvar(
    .new = list(
      "OSMEXT_DOWNLOAD_DIRECTORY" = tempdir(),
      "TESTTHAT" = "true"
    )
  )
  its_pbf = setup_pbf()

  sfnet = oe_get_sfnetwork("ITS Leeds", mode = "driving", quiet = TRUE)

  expect_s3_class(sfnet, "sfnetwork")

  expect_error(
    oe_get_sfnetwork(
      "ITS Leeds",
      mode = "driving",
      directed = "yes",
      quiet = TRUE
    ),
    "is.logical\\(directed\\) is not TRUE"
  )
})

test_that("oe_get_sfnetwork warns when oneway is missing", {
  withr::local_envvar(
    .new = list(
      "OSMEXT_DOWNLOAD_DIRECTORY" = tempdir(),
      "TESTTHAT" = "true"
    )
  )
  its_pbf = setup_pbf()

  expect_warning(
    sfnet <- oe_get_sfnetwork(
      "ITS Leeds",
      mode = "walking",
      directed = TRUE,
      quiet = TRUE
    ),
    regexp = "column is missing"
  )

  expect_s3_class(sfnet, "sfnetwork")
})

test_that("net_2_sfnet_undirected and prepare_directed return sfnetwork objects", {
  skip_if_not_installed("sfnetworks")
  toy_net = sf::st_sf(
    highway = c("residential", "residential"),
    oneway = c("no", "yes"),
    junction = c(NA, NA),
    z_order = c(1, 2),
    from = c(1, 2),
    to = c(2, 3),
    geometry = sf::st_sfc(
      sf::st_linestring(rbind(c(0, 0), c(1, 0))),
      sf::st_linestring(rbind(c(1, 0), c(2, 0))),
      crs = 4326
    )
  )

  undirected_net = net_2_sfnet_undirected(toy_net)
  directed_net = prepare_directed(undirected_net)

  expect_s3_class(undirected_net, "sfnetwork")
  expect_s3_class(directed_net, "sfnetwork")
})

test_that("oe_get_dodgrnetwork returns a dodgr_streetnet and applies highway filtering", {
  skip_if_not_installed("dodgr")
  withr::local_envvar(
    .new = list(
      "OSMEXT_DOWNLOAD_DIRECTORY" = tempdir(),
      "TESTTHAT" = "true"
    )
  )
  its_pbf = setup_pbf()

  graph = oe_get_dodgrnetwork(
    "ITS Leeds",
    mode = "driving",
    wt_profile = "motorcar",
    left_side = TRUE,
    highway_filter = c("residential", "service"),
    quiet = TRUE
  )

  expect_s3_class(graph, "dodgr_streetnet")
  expect_true(all(
    na.omit(unique(graph$highway)) %in% c("residential", "service")
  ))
  expect_false(any(grepl("_link", graph$highway, fixed = TRUE)))
})

test_that("oe_get_dodgrnetwork warns when oneway is missing", {
  skip_if_not_installed("dodgr")
  withr::local_envvar(
    .new = list(
      "OSMEXT_DOWNLOAD_DIRECTORY" = tempdir(),
      "TESTTHAT" = "true"
    )
  )
  its_pbf = setup_pbf()

  expect_warning(
    graph <- oe_get_dodgrnetwork(
      "ITS Leeds",
      mode = "walking",
      wt_profile = "foot"
    ),
    regexp = "column is missing"
  )

  expect_s3_class(graph, "dodgr_streetnet")
})

test_that("oe_get_sfnetwork validates and respects require_equal parameter", {
  skip_if_not_installed("sfnetworks")
  withr::local_envvar(
    .new = list(
      "OSMEXT_DOWNLOAD_DIRECTORY" = tempdir(),
      "TESTTHAT" = "true"
    )
  )
  its_pbf = setup_pbf()

  # Test parameter validation
  expect_error(
    oe_get_sfnetwork(
      "ITS Leeds",
      mode = "driving",
      require_equal = 123,
      quiet = TRUE
    )
  )
  expect_error(
    oe_get_sfnetwork(
      "ITS Leeds",
      mode = "driving",
      require_equal = "invalid_attribute",
      quiet = TRUE
    )
  )
})
