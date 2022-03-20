# Copy its-example.osm.pbf to tempdir(). See also
# https://github.com/ropensci/osmextract/issues/175
file.copy(
  system.file("its-example.osm.pbf", package = "osmextract"),
  file.path(tempdir(), "its-example.osm.pbf")
)
its_pbf = file.path(tempdir(), "its-example.osm.pbf")

test_that("oe_read: simplest examples work", {
  # Clean tempdir
  on.exit(
    oe_clean(tempdir()),
    add = TRUE,
    after = TRUE
  )

  # Read in data
  osm_data = oe_read(its_pbf, quiet = TRUE)

  # Run the tests. Check that result is sf object:
  expect_s3_class(object = osm_data, class = "sf")
  # Linestring geometry is default:
  expect_equal(
    as.character(unique(sf::st_geometry_type(osm_data))),
    "LINESTRING"
  )

  # Read-in points
  osm_data_points = oe_read(its_pbf, layer = "points", quiet = TRUE)
  expect_equal(
    as.character(unique(sf::st_geometry_type(osm_data_points))),
    "POINT"
  )
})

test_that("or_read: simplest example with a URL works", {
  skip_on_cran()
  skip_if_offline("github.com")

  my_url = "https://github.com/ropensci/osmextract/raw/master/inst/its-example.osm.pbf"
  expect_error(
    oe_read(
      my_url,
      provider = "test",
      quiet = TRUE,
      download_directory = tempdir()
    ),
    NA
  )

  # Clean tempdir
  file.remove(list.files(tempdir(), pattern = "its-example", full.names = TRUE))
})

# Refill tempdir
file.copy(
  system.file("its-example.osm.pbf", package = "osmextract"),
  file.path(tempdir(), "its-example.osm.pbf")
)
its_pbf = file.path(tempdir(), "its-example.osm.pbf")

test_that("oe_read fails with a clear error message with wrong URL or file path", {
  expect_error(
    oe_read("geofabrik_typo-in-path.osm.pbf"),
    "The input file_path does not correspond to any existing file and it doesn't look like a URL."
  )
})

test_that("oe_read fails with misspelled arguments", {
  # Run tests
  expect_error(
    suppressWarnings(oe_read(
      its_pbf,
      stringasfactor = FALSE,
      quiet = TRUE
    )),
    "no simple features"
  )

  # Remove the .gpkg file from the temp directory
  file.remove(list.files(tempdir(), pattern = "its-example.gpkg", full.names = TRUE))
})

test_that("extra_tags are not ignored when vectortranslate_options is not NULL", {
  its_gpkg = oe_read(
    its_pbf,
    quiet = TRUE,
    vectortranslate_options = c("-limit", 5L),
    extra_tags = c("oneway")
  )

  expect_true("oneway" %in% colnames(its_gpkg))

  # clean tempdir
  file.remove(list.files(tempdir(), pattern = "its-example.gpkg", full.names = TRUE))
})

# Create a fake osmconf_ini
custom_osmconf_ini = readLines(system.file("osmconf.ini", package = "osmextract"))
custom_osmconf_ini[[18]] = "report_all_nodes=yes"
custom_osmconf_ini[[21]] = "report_all_ways=yes"
temp_ini = tempfile(fileext = ".ini")
writeLines(custom_osmconf_ini, temp_ini)

test_that("osmconf_ini is not ignored when vectortranslate_options is not NULL", {
  # Regular output
  its_gpkg = oe_read(its_pbf, quiet = TRUE)
  # Ad hoc osmconf_ini + vectortranslate options
  its_gpkg_osmconf = oe_read(
    its_pbf,
    quiet = TRUE,
    osmconf_ini = temp_ini,
    vectortranslate_options = c("-t_srs", "EPSG:27700")
  )

  # Tests
  expect_gte(nrow(its_gpkg_osmconf), nrow(its_gpkg))
  expect_true(sf::st_is_longlat(its_gpkg))
  expect_false(sf::st_is_longlat(its_gpkg_osmconf))
})

test_that("warning with ad_hoc osmconf_ini + extra_tags", {
  # Warning with adhoc osmconf_ini + extra_tags
  expect_warning(
    oe_read(
      its_pbf,
      quiet = TRUE,
      osmconf_ini = temp_ini,
      vectortranslate_options = c("-t_srs", "EPSG:27700"),
      extra_tags = "oneway"
    )
  )
})

test_that("warning with ad-hoc osmconf_ini + CONFIG_FILE in vectortranslate_options", {
  # Warning
  expect_warning(
    oe_read(
      its_pbf,
      quiet = TRUE,
      osmconf_ini = temp_ini,
      vectortranslate_options = c("-t_srs", "EPSG:27700", "-oo", paste0("CONFIG_FILE=", temp_ini)),
    )
  )
})

# Define a small polygon in the area of ITS Leeds
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

test_that("boundary and boundary_type arguments from oe_vectortranslate works", {
  # Spatial filters work
  its = oe_read(its_pbf, quiet = TRUE)
  its_spat = oe_read(its_pbf, boundary = its_poly %>% sf::st_transform(27700), quiet = TRUE)
  its_clipsrc = oe_read(its_pbf, boundary = its_poly, quiet = TRUE, boundary_type = "clipsrc")
  expect_lte(nrow(its_spat), nrow(its))
  expect_lte(nrow(its_clipsrc), nrow(its_spat))
})

test_that("spatial filters work with bbox objects", {
  its_spat = oe_read(its_pbf, boundary = its_poly %>% sf::st_transform(27700), quiet = TRUE)
  its_spat_bbox = oe_read(its_pbf, boundary = its_poly %>% sf::st_transform(27700) %>% sf::st_bbox(), quiet = TRUE)
  expect_gte(nrow(its_spat_bbox), nrow(its_spat))
})

test_that("we can combine boundary = ... with other vectortranslate arguments", {
  its_spat = oe_read(its_pbf, boundary = its_poly %>% sf::st_transform(27700), quiet = TRUE)
  its_clipsrc = oe_read(its_pbf, boundary = its_poly, quiet = TRUE, boundary_type = "clipsrc")
  its_clipsrc_small = oe_read(its_pbf, boundary = its_poly, quiet = TRUE, boundary_type = "clipsrc", vectortranslate_options = c("-where", "highway = 'footway'"))
  expect_lte(nrow(its_clipsrc_small), nrow(its_spat))
  expect_equal(nrow(its_clipsrc_small), sum(its_clipsrc[["highway"]] == "footway", na.rm = TRUE))
})

test_that("get a warning for more than 1 polygon in boundary = ...", {
  # Warning for more than 1 POLYGON
  expect_warning(oe_read(its_pbf, boundary = c(its_poly, its_poly), quiet = TRUE))
})

test_that("get error when boundary is not a POLYGON/MULTIPOLYGON", {
  # Error for non POLYGON boundary. I need suppressWarnings for the warning on
  # centroids for lat/long data
  suppressWarnings(expect_error(oe_read(its_pbf, boundary = sf::st_centroid(its_poly), quiet = TRUE)))
})

test_that("warning when setting boundary and spat/clipsrc options", {
  expect_warning(oe_read(
    file_path = its_pbf,
    boundary = its_poly,
    vectortranslate_options = c("-spat", sf::st_bbox(its_poly)),
    quiet = TRUE
  ))
  expect_warning(oe_read(
    file_path = its_pbf,
    boundary = its_poly,
    boundary_type = "clipsrc",
    vectortranslate_options = c("-clipsrc", sf::st_as_text(its_poly)),
    quiet = TRUE
  ))
})

test_that("oe_read returns an error with unnamed arguments", {
  expect_error(
    oe_read(
      file_path = its_pbf,
      layer = "lines",
      "SELECT * FROM lines"
    ),
    class = "osmext-names-dots-error"
  )
})

test_that("oe_read returns an error with named and unnamed arguments", {
  expect_error(
    oe_read(
      file_path = its_pbf,
      layer = "lines",
      query = "SELECT * FROM lines",
      "ABC"
    ),
    class = "osmext-names-dots-error"
  )
})

test_that("oe_read returns an error with extra comma", {
  expect_error(
    oe_read(
      file_path = its_pbf,
      layer = "lines",
    ),
    class = "osmext-names-dots-error"
  )
})

test_that("oe_read returns an error with named argument + extra comma", {
  expect_error(
    oe_read(
      file_path = its_pbf,
      layer = "lines",
      query = "SELECT * FROM lines",
    ),
    class = "osmext-names-dots-error"
  )
})

test_that("oe_read returns an error with unnamed argument and extra comma", {
  expect_error(
    oe_read(
      file_path = its_pbf,
      layer = "lines",
      query = "SELECT * FROM lines",
    ),
    class = "osmext-names-dots-error"
  )
})

# Clean tempdir
rm(its_poly)
oe_clean(tempdir())
