test_that("tidy_highway strips _link suffix and filters values", {
    toy_net <- sf::st_sf(
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

    filtered_net <- tidy_highway(
        toy_net,
        highway_filter = c("primary", "residential")
    )

    expect_identical(filtered_net$highway, c("primary", "residential"))
    expect_false(any(grepl("_link", filtered_net$highway, fixed = TRUE)))
    expect_equal(nrow(filtered_net), 2L)
})

test_that("tidy_oneway standardises values and reverses -1 geometries", {
    toy_net <- sf::st_sf(
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

    tidy_net <- tidy_oneway(toy_net, implied_oneway = TRUE)

    expect_identical(tidy_net$oneway, c("yes", "no", "no", "yes", "no"))

    reversed_coords <- sf::st_coordinates(tidy_net$geometry[4])
    expect_identical(
        unname(reversed_coords[, c("X", "Y")]),
        matrix(c(4, 0, 3, 0), ncol = 2, byrow = TRUE)
    )
})

test_that("oe_get_tidynetwork adds the required tags and tidies the sample network", {
    withr::local_envvar(
        .new = list(
            "OSMEXT_DOWNLOAD_DIRECTORY" = tempdir(),
            "TESTTHAT" = "true"
        )
    )
    its_pbf <- setup_pbf()

    tidynet <- oe_get_tidynetwork("ITS Leeds", mode = "driving", quiet = TRUE)

    expect_s3_class(tidynet, "sf")
    expect_true(all(c("highway", "oneway", "junction") %in% names(tidynet)))
    expect_false(any(grepl("_link", tidynet$highway, fixed = TRUE)))
    expect_true(all(tidynet$oneway %in% c("yes", "no")))
})

test_that("oe_get_tidynetwork validates simplify_highway", {
    withr::local_envvar(
        .new = list(
            "OSMEXT_DOWNLOAD_DIRECTORY" = tempdir(),
            "TESTTHAT" = "true"
        )
    )
    its_pbf <- setup_pbf()

    expect_error(
        oe_get_tidynetwork(
            "ITS Leeds",
            mode = "driving",
            simplify_highway = "yes",
            quiet = TRUE
        ),
        "logical value"
    )
})

test_that("oe_get_sfnetwork returns an sfnetwork and validates directed", {
    withr::local_envvar(
        .new = list(
            "OSMEXT_DOWNLOAD_DIRECTORY" = tempdir(),
            "TESTTHAT" = "true"
        )
    )
    its_pbf <- setup_pbf()

    sfnet <- oe_get_sfnetwork("ITS Leeds", mode = "driving", quiet = TRUE)

    expect_s3_class(sfnet, "sfnetwork")

    expect_error(
        oe_get_sfnetwork(
            "ITS Leeds",
            mode = "driving",
            directed = "yes",
            quiet = TRUE
        ),
        "logical value"
    )
})

test_that("net_2_sfnet_undirected and prepare_directed return sfnetwork objects", {
    toy_net <- sf::st_sf(
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

    undirected_net <- net_2_sfnet_undirected(toy_net)
    directed_net <- prepare_directed(undirected_net)

    expect_s3_class(undirected_net, "sfnetwork")
    expect_s3_class(directed_net, "sfnetwork")
})

test_that("oe_get_dodgrnetwork returns a dodgr_streetnet and applies highway filtering", {
    withr::local_envvar(
        .new = list(
            "OSMEXT_DOWNLOAD_DIRECTORY" = tempdir(),
            "TESTTHAT" = "true"
        )
    )
    its_pbf <- setup_pbf()

    graph <- oe_get_dodgrnetwork(
        "ITS Leeds",
        mode = "driving",
        wt_profile = "motorcar",
        left_side = TRUE,
        highway_filter = c("residential", "service"),
        quiet = TRUE
    )

    expect_s3_class(graph, "dodgr_streetnet")
    expect_true(all(na.omit(unique(graph$highway)) %in% c("residential", "service")))
    expect_false(any(grepl("_link", graph$highway, fixed = TRUE)))
})
