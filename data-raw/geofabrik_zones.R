## code to prepare `geofabrik_zones` dataset goes here

# packages
library(sf)
library(jsonlite)
library(purrr)
library(httr)
library(dplyr)
library(rvest)
library(s2)
library(conflicted)

conflict_prefer("filter", "dplyr", quiet = TRUE)

# Download official description of geofabrik data.
geofabrik_zones = st_read("https://download.geofabrik.de/index-v1.json", stringsAsFactors = FALSE) %>%
  janitor::clean_names()

# Check the result
str(geofabrik_zones, max.level = 1, nchar.max = 64, give.attr = FALSE)

# There are a few problems with the ISO3166 columns (i.e. they are read as list
# columns with character(0) instead of NA/NULL).
my_fix_iso3166 = function(list_column) {
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
geofabrik_zones$iso3166_2 = my_fix_iso3166(geofabrik_zones$iso3166_2)
geofabrik_zones$iso3166_1_alpha2 = my_fix_iso3166(geofabrik_zones$iso3166_1_alpha2)
rm(my_fix_iso3166)

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

(geofabrik_urls = map_dfr(geofabrik_zones$urls, fromJSON))
geofabrik_zones$urls = NULL # This is just to remove the urls column

# From rbind.sf docs: If you need to cbind e.g. a data.frame to an sf, use
# data.frame directly and use st_sf on its result, or use bind_cols; see
# examples.
geofabrik_zones = st_sf(data.frame(geofabrik_zones, geofabrik_urls))
rm(geofabrik_urls)

# Now we are going to add to the geofabrik_zones object other useful information
# for each pbf file such as the file size. Parents extracted by hand from
# http://download.geofabrik.de/europe/ and similar pages.

# Define parents
parents <- c(
  "africa",
  "asia", "asia/india", "asia/indonesia", "asia/japan",
  "australia-oceania",
  "central-america",
  "europe", "europe/france",
  "europe/germany", "europe/germany/baden-wuerttemberg",
  "europe/germany/bayern", "europe/germany/nordrhein-westfalen",
  "europe/great-britain", "europe/great-britain/england",
  "europe/great-britain/england/london/",
  "europe/italy",
  "europe/netherlands",
  "europe/poland",
  "europe/spain",
  "north-america", "north-america/canada", "north-america/us", "north-america/us/california/",
  "russia",
  "south-america", "south-america/brazil"
)

size_table <- map_dfr(
  .x = parents,
  .f = function(parent) {
    # Read-in row table
    url <- paste0("https://download.geofabrik.de/", parent, "/")
    table <- read_html(url) |> html_table()

    # Subset table and extract only "latest" ".osm.pbf" files
    lapply(
      table,
      function(x, parent) {
        x |>
          janitor::clean_names() |>
          filter(grepl("-latest.osm.pbf$", name, perl = TRUE)) |>
          mutate(parent = parent)
      },
      parent = parent
    )
  }
)

# Add highest level parents by hand
size_table <- bind_rows(
  size_table,
  data.frame(
    x = NA,
    name = c(
      "africa-latest.osm.pbf", "antarctica-latest.osm.pbf", "asia-latest.osm.pbf",
      "australia-oceania-latest.osm.pbf", "central-america-latest.osm.pbf",
      "europe-latest.osm.pbf", "north-america-latest.osm.pbf",
      "russia-latest.osm.pbf", "south-america-latest.osm.pbf"
    ),
    last_modified = NA,
    size = c(
      "5.6G", "31.1M", "11.5G", "1.0G", "590M", "26.3G", "12.1G", "3.2G", "3.0G"
    ),
    description = NA
  )
)

# Add id and remove useless stuff
size_table <- size_table |>
  select(-x, -description, -last_modified) |>
  mutate(
    unit = regmatches(size, regexpr("[a-zA-Z]+", size, perl = TRUE)),
    size = readr::parse_number(size),
  ) |>
  mutate(
    id = regmatches(name, regexpr("[a-z-]+(?=-latest)", name, perl = TRUE))
  ) |>
  mutate(
    pbf_file_size = case_when(
      unit == "K" ~ size * 1000,
      unit == "M" ~ size * 1000 ^ 2,
      unit == "G" ~ size * 1000 ^ 3
    )
  ) |>
  select(-size, -unit)

# Fix some tiny problems
size_table <- size_table |>
  mutate(
    id = case_when(
      parent == "north-america/us" ~ paste0("us/", id),
      .default = id
    )
  )

geofabrik_zones <- inner_join(
  x = geofabrik_zones,
  y = size_table |> select(-name, -parent),
  by = "id"
)
rm(size_table, parents)

# Add a new column named "level", which is used for spatial matching. It has
# four categories named "1", "2", "3", and "4", and it is based on the geofabrik
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
# - level = 4 are the subregions of level 3 (mainly related to some small areas
# in Germany)

geofabrik_zones = geofabrik_zones %>%
  mutate(
    level = case_when(
      is.na(parent) ~ 1L,
      parent %in% c(
        "africa", "asia", "australia-oceania", "central-america", "europe",
        "north-america", "south-america", "great-britain"
      )             ~ 2L,
      parent %in% c(
        "baden-wuerttemberg", "bayern", "greater-london", "nordrhein-westfalen"
      )             ~ 4L,
      TRUE          ~ 3L
    )
  ) %>%
  select(id, name, parent, level, iso3166_1_alpha2, iso3166_2, pbf_file_size, everything())

# Fix problem with S2 (see https://github.com/ropensci/osmextract/issues/194 and
# https://github.com/r-spatial/sf/issues/1649)
st_geometry(geofabrik_zones) <- st_as_sfc(
  s2_rebuild(s2_geog_from_wkb(st_as_binary(st_geometry(geofabrik_zones)), check = FALSE))
)

# Remove (typically) useless column
geofabrik_zones$pbf.internal = NULL
geofabrik_zones$history = NULL
geofabrik_zones$taginfo = NULL
geofabrik_zones$updates = NULL

# The end
usethis::use_data(geofabrik_zones, version = 3, overwrite = TRUE, compress = "xz")
