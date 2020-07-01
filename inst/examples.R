# List of examples
osmext_get("Monaco", "points", stringsAsFactors = FALSE) # Monaco (City - State)
osmext_get(c(7.418498, 43.72633))
# Numeric vector of coordinates assuming EPSG:4326. Note that this gives a
# different result wrt to the previous function call
osmext_get(sf::st_sfc(sf::st_point(c(372622, 4842692)), crs = 32632)) # Manual creation of point

osmext_get("Andorra", layer = "lines")
osmext_get("Liechtenstein", layer = "lines")

osmext_get(c("Monaco", "italy"))
osmext_get("Monaco", provider = "bbbike") # Add example with another provider
osmext_get("USA") # show how to use alternative match_by variables (i.e. iso3166)
osmext_get("US", match_by = "iso3166_1_alpha2")
osmext_get("London") # show how to use check_pattern function
osmext_check_pattern("London")
osmext_get("Greater London")
osmext_check_pattern("us/") # US states
osmext_check_pattern("italy", match_by = "parent") # FIXME
osmext_check_pattern("Yorkshire")
osmext_check_pattern("england", match_by = "parent") #FIXME

osmext_get("Amsterdam", provider = "bbbike")
