################################################################################
# NB: ALWAYS REMEMBER TO SET                                                   #
# withr::local_envvar(                                                         #
#   .new = list("OSMEXT_DOWNLOAD_DIRECTORY" = tempdir())                       #
# )                                                                            #
# IF YOU NEED TO MODIFY THE OSMEXT_DOWNLOAD_DIRECTORY envvar INSIDE THE TESTS. #
################################################################################

test_that("oe_update(): simplest example works", {
  skip_on_ci() # I can just run these tests on local laptop
  skip_on_cran()
  # I always need internet connection when running oe_update()
  skip_if_offline("download.openstreetmap.fr")

  # Clean tempdir on exit
  on.exit(
    oe_clean(tempdir()),
    add = TRUE,
    after = TRUE
  )

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

  seva <- oe_get("Sevastopol", download_directory = tempdir(), quiet = TRUE) # smallest openstreetmap.fr extract
  expect_error(oe_update(tempdir(), quiet = TRUE), NA)

  # AG: I decided to comment out that test since I don't see any benefit testing
  # the "verbose" output during R CMD checks (something that I rarely check
  # manually)

  # expect_message(oe_update(fake_dir, quiet = FALSE))
  # file.remove(list.files(tempdir(), pattern = "its-example", full.names = TRUE))
})
