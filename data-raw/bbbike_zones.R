# packages
library(sf)
library(s2)
library(rvest)
library(httr)
devtools::load_all(".")
library(conflicted)

# Download and process data
webpage <- read_html("https://download.bbbike.org/osm/bbbike/")
table <- html_table(webpage)[[1]]

# Check output
table

# We need to remove the first row, the "Size" and "Type" columns and clean names
table <- janitor::clean_names(table[-1, c("Name"), drop = FALSE])

# Remove the trailing "/" from the name
table[["name"]] <- gsub("/", "", table[["name"]])

# Define the URL for the .poly file
poly_url <- paste0("https://download.bbbike.org/osm/bbbike/", table[["name"]], "/", table[["name"]], ".poly")

# Define the URL for the pbf
table[["pbf"]] <- paste0("https://download.bbbike.org/osm/bbbike/", table[["name"]], "/", table[["name"]], ".osm.pbf")

# Add the file_size
table[["pbf_file_size"]] <- vapply(
  X = table[["pbf"]],
  FUN = function(x) as.numeric(headers(HEAD(x))$`content-length`),
  FUN.VALUE = numeric(1),
  USE.NAMES = FALSE
)

# Add id and level
table[["id"]] <- table[["name"]]
table[["level"]] <- 3L

# Download the geometries
polies <- do.call(c, lapply(poly_url, read_poly))

# Create the output object
table <- st_sf(table, geometry = polies)

# Fix problem with S2 (see https://github.com/ropensci/osmextract/issues/194 and
# https://github.com/r-spatial/sf/issues/1649)
st_geometry(table) <- st_as_sfc(
  s2_rebuild(s2_geog_from_wkb(st_as_binary(st_geometry(table)), check = FALSE))
)

# Check the geoms are fine
all(st_is_valid(table))

bbbike_zones <- table

usethis::use_data(bbbike_zones, version = 3, overwrite = TRUE, compress = "xz")
