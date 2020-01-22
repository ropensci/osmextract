library(sf)
download.file("http://download.geofabrik.de/europe/great-britain/england/greater-london-latest.osm.pbf", "greater-london-latest.osm.pbf", mode = "wb")

greater_london <- st_read(
  "greater-london-latest.osm.pbf",
  layer = "lines",
  stringsAsFactors = FALSE
  # , options = "INTERLEAVED_READING=YES"
  , options = "OGR_INTERLEAVED_READING=YES"
  )

greater_london <- st_read(
  "greater-london-latest.osm.pbf",
  layer = "lines",
  stringsAsFactors = FALSE
  # , options = "INTERLEAVED_READING=YES"
  , options = "rl"
)

gdal_utils(
  util = "vectortranslate",
  source = "greater-london-latest.osm.pbf",
  destination = "greater-london-latest.gpkg",
  options = c("-f", "GPKG")
)
gl = read_sf("greater-london-latest.gpkg")
gl
greater_london_gpkg = read_sf("greater-london-latest.gpkg", layer = "lines")
nrow(greater_london_gpkg)


ogr2ogr out.gpkg greater-london-latest.osm.pbf lines
ogrinfo out.gpkg
ogrinfo -oo out.gpkg lines > x5
head -n 5 x5

l = read_sf("out.gpkg")

read = function() system("ogrinfo -rl greater-london-latest.osm.pbf lines > x4")
convert = function() system("ogr2ogr out.gpkg greater-london-latest.osm.pbf lines")
bench::mark(iterations = 1, check = FALSE, read(), convert())

sf::gdal_utils(
  util = "vectortranslate",
  source = "greater-london-latest.osm.pbf",
  destination = "out2.gpkg",
  options = c("-f", "GPKG", "lines")
)

l2 = read_sf("out2.gpkg")
l2

# new reprex

library(sf)
setwd("~/atfutures/who-data/")

get1 = function(x = "greater-london-latest.osm.pbf", highway_type = "residential") {
  x_gpkg = paste0(x, ".gpkg")
  gdal_utils(
    util = "vectortranslate",
    source = x,
    destination = x_gpkg,
    options = c("-f", "GPKG")
  )
  full_res = read_sf(x_gpkg, layer = "lines")
  full_res[full_res$highway == highway_type, ]
}

get2 = function(x = "greater-london-latest.osm.pbf", highway_type = "residential") {
  q = paste0("SELECT * FROM lines WHERE (highway = '", highway_type, "')")
  read_sf(x, layer = "lines", query = q)
}

get3 = function(x = "greater-london-latest.osm.pbf", highway_type = "residential") {
  q = paste0("SELECT * FROM lines WHERE (highway = '", highway_type, "')")
  dest_filename = paste0(x, ".gpkg")
  if(!file.exists(dest_filename)) {
    sf::gdal_utils(
      util = "vectortranslate",
      source = "greater-london-latest.osm.pbf",
      destination = dest_filename,
      options = c("-f", "GPKG", "lines")
    )
  }
  st_read(dest_filename, query = q)
}

h1 = get1()
h2 = get2()
h3 = get3()
nrow(h1)
nrow(h2)
nrow(h3)

bench::mark(iterations = 1, check = FALSE, get1(), get2(), get3(), get3())


rutland <- download.file(
  url = "http://download.geofabrik.de/europe/great-britain/england/rutland-latest.osm.pbf",
  destfile = "rutland-latest.osm.pbf",
  mode = "wb"
)

my_ini_file <- paste0(tempfile(), ".ini")
writeLines(
  text = geofabric::make_ini_attributes(c("maxspeed", "oneway", "lanes"), layer = "lines", append = TRUE),
  con = my_ini_file
)

my_gpkg_file <- paste0(tempfile(), ".gpkg")
sf::gdal_utils(
  util = "vectortranslate",
  source = "rutland-latest.osm.pbf",
  destination = my_gpkg_file,
  options = c("-f", "GPKG", "-oo", paste0("CONFIG_FILE=", my_ini_file), "lines")
)
sf::st_read(my_gpkg_file, layer = "lines")

sf::gdal_utils(
  util = "vectortranslate",
  source = "rutland-latest.osm.pbf",
  destination = my_gpkg_file,
  options = c("-f", "GPKG", "lines", "rutland-latest.osm.pbf", paste0("CONFIG_FILE=", my_ini_file))
)

sf::st_read(my_gpkg_file, layer = "lines")
