#' Read a `.poly` file.
#'
#' @param input Character vector representing a polygon object saved using the
#'   `.poly` format. Can be also a path to a file or a URL pointing to a valid
#'   `.poly` file.
#' @param crs The Coordinate Reference System (CRS) of the input polygon.
#' @param ... Further arguments passed to `readLines()` (which is the function
#'   used to read external `.poly` files).
#'
#' @details The Polygon Filter File Format (`.poly`) is defined
#'   [here](https://wiki.openstreetmap.org/wiki/Osmosis/Polygon_Filter_File_Format).
#'    The code behind the function was inspired by the `parse_poly` function
#'   defined
#'   [here](https://wiki.openstreetmap.org/wiki/Osmosis/Polygon_Filter_File_Python_Parsing).
#'
#'   [Geofabrik](https://download.geofabrik.de/) stores the `.poly` files used
#'   to generate their extracts. Furthermore, a nice collection of exact-border
#'   poly files created from cities with an OSM Relation ID is available in this
#'   git repository on github: <https://github.com/jameschevalier/cities>.
#'
#'   The default value for the `crs` argument is "OGC:CRS84" instead of "4326"
#'   or "EPSG:4326" since, by definition, the coordinates are provided as
#'   "longitude, latitude" (but these differences should be relevant only when
#'   `sf::st_axis_order()` is `TRUE`).
#'
#' @return A `sfc_MULTIPOLYGON`/`sfc` object.
#' @export
#'
#' @examples
#' toy_poly <- c(
#'   "test_poly",
#'   "first_area",
#'   "0 0",
#'   "0 1",
#'   "1 1",
#'   "1 0",
#'   "0 0",
#'   "END",
#'   "END"
#' )
#' (out <- read_poly(toy_poly))
#' plot(out)
#'
#' \dontrun{
#' italy_poly <- "https://download.geofabrik.de/europe/italy.poly"
#' plot(read_poly(italy_poly))}
read_poly <- function(input, crs = "OGC:CRS84", ...) {
  # Minimal requirements
  stopifnot(is.character(input))

  # If input is a character vector of length 1, then it should be a path or a URL
  if (length(input) == 1L) {
    if (file.exists(input)) {
      input <- readLines(input, ...)
    } else if (is_like_url(input)) {
      on.exit(close(con), add = TRUE, after = TRUE)
      con <- url(input)
      input <- readLines(con, ...)
    } else {
      oe_stop(
        .subclass = "read_poly-noURLorFileExists",
        message = paste0(
          "The input object does not point to an existing file ",
          "and does not look like a URL."
        )
      )
    }
  }

  # I will store all polygon(s) (with their ring(s)) in a list called
  # multipolygon_list
  multipolygon_list <- list()
  index_multipolygon <- 1L

  # I will store each polygon with its ring(s) in a list called
  # polygon_list
  polygon_list <- list()
  index_polygon <- 1L

  # I will store each matrix of coordinates in a list called coords_list
  coords_list <- list()

  # The following is used to skip the lines containing a name which begins a
  # section that define an individual polygon or ring
  skip_line <- FALSE

  # Loop over all rows in the .poly file. They should follow the structure described
  # here: https://wiki.openstreetmap.org/wiki/Osmosis/Polygon_Filter_File_Format

  # The for loop starts from 3 since I ignore the first line because it contains
  # the name of the file (without any consistent naming convention) and the
  # second line is just the name of the polygon in the first section.

  for (i in seq.int(from = 3, to = length(input))) {

    # Ignore the lines containing a name which begins a section defining an
    # individual polygon.
    if (skip_line) {
      skip_line <- FALSE
      next
    }

    if (input[i] != "END") {
      # When input[[i]] == "END", then we reached the end of the polygon/ring.
      # Now we are working on the coordinates, which, in the .poly file, are
      # divided by some blank character (space or tab, I think).
      # The coordinates will be divided into two.
      # coords_list is now a list of character coordinates.
      coords_list[i] <- strsplit(trimws(input[[i]]), "[[:blank:]]+")
      next()
    }

    # Now we reached a line with "END", so we must transform the character
    # coordinates into a numeric matrix
    coord_matrix <- do.call("rbind", coords_list)
    coord_matrix <- apply(coord_matrix, 2, as.numeric)

    # Check that the polygon/ring is closed, otherwise append a further point
    # closing the polygon
    if (any(coord_matrix[1, ] != coord_matrix[nrow(coord_matrix), ])) {
      coord_matrix <- rbind(coord_matrix, coord_matrix[1, ])
    }

    # Add the numeric matrix into polygon_list
    polygon_list[index_polygon] <- list(coord_matrix)
    index_polygon <- index_polygon + 1L

    # Check if we reached the EOF
    if (input[i + 1] == "END") {
      multipolygon_list[index_multipolygon] <- list(polygon_list)
      break()
    }

    # Check if the next section represents a polygon
    if (!grepl("!", input[i + 1L])) {
      # Write the polygon into multipolygon_list
      multipolygon_list[index_multipolygon] <- list(polygon_list)
      index_multipolygon <- index_multipolygon + 1L

      # Reset values
      polygon_list <- list()
      index_polygon <- 1L
      coords_list <- list()

      # skip one line
      skip_line <- TRUE
      next
    }

    # Check if next section represents a ring
    if (grepl("!", input[i + 1L])) {
      # reset values
      coords_list <- list()

      # skip one line
      skip_line <- TRUE
      next
    }
  }

  # Format result as sfc object
  sf::st_sfc(
    sf::st_multipolygon(multipolygon_list),
    crs = crs
  )
}
