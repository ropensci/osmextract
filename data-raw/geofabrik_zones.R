## code to prepare `geofabrik_zones` dataset goes here

# packages
library(sf)
library(jsonlite)
library(purrr)
library(httr)

# Download official description of geofabrik data.
geofabrik_zones <- st_read("https://download.geofabrik.de/index-v1.json", stringsAsFactors = FALSE) %>%
  janitor::clean_names()

# Check the result
str(geofabrik_zones, max.level = 1, nchar.max = 64, give.attr = FALSE)

# There are a few problems with the ISO3166 columns (i.e. they are read as list
# columns with character(0) instead of NA/NULL).
my_fix_iso3166 <- function(list_column) {
  vapply(
    list_column,
    function(x) {
      if (identical(x, character(0))) {
        NA_character_
      } else {
        paste(x, collapse = " ")
      }
    },
    character(1)
  )
}

# We used the paste function in the else case because there are a few record
# where the ISO3166 code is composed by two or more elements, such as c("PS", "IL")
# for Israel and Palestine, c("SN", "GM") for Senegal and Gambia. The same
# situation happens with the US states where the ISO3166 code is c("US", state).
geofabrik_zones$iso3166_2 <- my_fix_iso3166(geofabrik_zones$iso3166_2)
geofabrik_zones$iso3166_1_alpha2 <- my_fix_iso3166(geofabrik_zones$iso3166_1_alpha2)

# We need to preprocess the urls column since it was read in a JSON format:
# geofabrik_zones$urls[[1]]
# "{
#   \"pbf\": \"https:\\/\\/download.geofabrik.de\\/asia\\/afghanistan-latest.osm.pbf\",
#   \"bz2\": \"https:\\/\\/download.geofabrik.de\\/asia\\/afghanistan-latest.osm.bz2\",
#   \"shp\": \"https:\\/\\/download.geofabrik.de\\/asia\\/afghanistan-latest-free.shp.zip\",
#   \"pbf-internal\": \"https:\\/\\/osm-internal.download.geofabrik.de\\/asia\\/afghanistan-latest-internal.osm.pbf\",
#   \"history\": \"https:\\/\\/osm-internal.download.geofabrik.de\\/asia\\/afghanistan-internal.osh.pbf\",
#   \"taginfo\": \"https:\\/\\/taginfo.geofabrik.de\\/asia\\/afghanistan\\/\",
#   \"updates\": \"https:\\/\\/download.geofabrik.de\\/asia\\/afghanistan-updates\"
# }"

geofabrik_urls <- map_dfr(geofabrik_zones$urls, fromJSON)
geofabrik_urls
geofabrik_zones$urls <- NULL # This is just to remove the urls column

# From rbind.sf docs: If you need to cbind e.g. a data.frame to an sf, use
# data.frame directly and use st_sf on its result, or use bind_cols; see
# examples.
geofabrik_zones <- st_sf(data.frame(geofabrik_zones, geofabrik_urls))

# Now we are going to add to the geofabrik_zones sf object other useful
# information for each pbf file such as it's content-length (i.e. the file size
# in bytes). We can get this information from the headers of each file.
# Idea from:
# https://stackoverflow.com/questions/2301009/get-file-size-before-downloading-counting-how-much-already-downloaded-httpru/2301030

geofabrik_zones$pbf_file_size <- map_dbl(
  .x = geofabrik_zones$pbf,
  .f = function(x) as.numeric(headers(HEAD(x))$`content-length`)
)

# Add a new column named "level", which is used for spatial matching. It has
# three categories named "1", "2" and "3", and it is based on the geofabrik
# column "parent". It is defined as follows:
# - level = 1 when parent == NA. This happens for the continents plus the
# Russian Federation. More precisely it occurs for: Africa, Antarctica, Asia,
# Australia and Oceania, Central America, Europe, North America, Russian
# Federation and South America;
# - level = 2 correspond to each continent subregion such as Italy, Great
# Britain, Spain, USA, Mexico, Belize, Morocco, Peru ...
# There are also a few exceptions that correspond to the Special Sub Regions
# (according to the geofabrik definition), which are: South Africa (includes
# Lesotho), Alps, Britain and Ireland, Germany + Austria + Switzerland, US
# Midwest, US Northeast, US Pacific, US South, US West and all US states;
# - level = 3 correspond to the subregions of level 2 region. For example the
# West Yorkshire, which is a subregion of England, is a level 3 zone.

library(dplyr)
geofabrik_zones <- geofabrik_zones %>%
  mutate(
    level = case_when(
      is.na(parent) ~ 1L,
      parent %in% c(
        "africa", "asia", "australia-oceania", "central-america", "europe",
        "north-america", "south-america"
      )             ~ 2L,
      TRUE          ~ 3L
    )
  ) %>%
  select(id, name, parent, level, iso3166_1_alpha2, iso3166_2, pbf_file_size, everything())

# The end
usethis::use_data(geofabrik_zones, overwrite = TRUE)

# create test provider
oe_get(place = "Isle of Wight", download_directory = ".")
piggyback::pb_upload("geofabrik_isle-of-wight-latest.osm.pbf")
u = piggyback::pb_download_url("geofabrik_isle-of-wight-latest.osm.pbf")
test_zones = geofabrik_zones
test_zones = test_zones[test_zones$name == "Isle of Wight", ]
test_zones$pbf = u
usethis::use_data(test_zones, version = 3)
