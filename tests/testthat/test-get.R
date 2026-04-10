test_that("oe_get: simplest examples work", {
  skip_on_cran()
  skip_if_offline("github.com")
  withr::local_envvar(
    .new = list(
      "OSMEXT_DOWNLOAD_DIRECTORY" = tempdir(),
      "TESTTHAT" = "true"
    )
  )
  withr::defer(oe_clean(tempdir()))

  expect_s3_class(
    oe_get("ITS Leeds", provider = "test", quiet = TRUE),
    "sf"
  )
})

test_that("We can specify a path using ~", {
  # I think that we cannot safely add a directory on CRAN tests
  # See also https://github.com/ropensci/osmextract/issues/175
  skip_on_cran()
  skip_if_offline("github.com")
  withr::defer(unlink("~/test_for_tilde_in_R_osmextract", recursive = TRUE))

  dir.create("~/test_for_tilde_in_R_osmextract")
  expect_s3_class(
    object = oe_get(
      place = "ITS Leeds",
      download_directory = "~/test_for_tilde_in_R_osmextract",
      quiet = TRUE
    ),
    class = "sf"
  )

})

test_that("The provider is overwritten when oe_match finds a different provider", {
  # See https://github.com/ropensci/osmextract/issues/245
  withr::local_envvar(
    .new = list(
      "OSMEXT_DOWNLOAD_DIRECTORY" = tempdir(),
      "TESTTHAT" = "true"
    )
  )
  withr::defer(oe_clean(tempdir()))

  skip_on_ci() # I can just run these tests on local laptop
  skip_on_cran()
  skip_if_offline("download.openstreetmap.fr")

  # I should also check the status code of the provider
  my_status <- try(
    httr::status_code(
      httr::GET(
        "https://download.openstreetmap.fr/",
        httr::timeout(15L)
      )
    ),
    silent = TRUE
  )
  skip_if(inherits(my_status, "try-error"))
  skip_if_not(my_status == 200L)

  expect_match(
    oe_get("Sevastopol", download_only = TRUE, skip_vectortranslate = TRUE, quiet = TRUE),
    regexp = "openstreetmap_fr"
  )
})

test_that("place = sf/sfc and boundary = NULL correctly filters input object", {
  # See discussion in https://github.com/ropensci/osmextract/issues/313
  withr::local_envvar(
    .new = list(
      "OSMEXT_DOWNLOAD_DIRECTORY" = tempdir(),
      "TESTTHAT" = "true"
    )
  )
  its_pbf = setup_pbf()

  # Define a toy boundary object within ITS
  its_poly = sf::st_sfc(
    sf::st_polygon(
      list(rbind(
        c(-1.55577, 53.80850),
        c(-1.55787, 53.80926),
        c(-1.56096, 53.80891),
        c(-1.56096, 53.80736),
        c(-1.55675, 53.80658),
        c(-1.55495, 53.80749),
        c(-1.55577, 53.80850)
      ))
    ),
    crs = 4326
  )

  # Old approach: Read and manually apply the boundary filter
  old <- oe_get("ITS Leeds", boundary = its_poly, quiet = TRUE)

  # New approach: Just set the boundary object as the first argument
  new <- oe_get(its_poly, provider = "test", quiet = TRUE)

  expect_identical(old, new)

  # Boundary = NA forces the full import
  full_new <- oe_get(its_poly, provider = "test", boundary = NA, quiet = TRUE)
  full_old <- oe_get("ITS Leeds", force_vectortranslate = TRUE, quiet = TRUE)
  expect_identical(full_old, full_new)
})
