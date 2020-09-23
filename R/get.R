#' Download, translate and read OSM extracts from several providers
#'
#' This function is used to download, translate and read OSM extracts obtained
#' from several providers. It is a wrapper around [oe_match()] and [oe_read()].
#' Check the introductory vignette, the examples and the help pages of the
#' wrapped functions to understand the details behind all parameters.
#'
#' To learn how to use the `query` argument, for example, see the
#' [query section of the osmextract vignette](https://itsleeds.github.io/osmextract/articles/osmextract.html#query).
#'
#' @param place Description of the geographical area that should be matched with
#'   a `.osm.pbf` file through the chosen `provider`. Can be either a length-1
#'   character vector, a length-1 `sfc_POINT` object or a numeric vector of
#'   coordinates with length 2. In the latter case it is assumed that the EPSG
#'   code is 4326, while you can use any EPSG code with an `sfc_POINT` object.
#'   See Details and examples in [oe_match()].
#' @param layer Which `layer` should be read in? Typically `points`, `lines`
#' (the default), `multilinestrings`, `multipolygons` or `other_relations`.
#' @param provider Which provider should be used to download the data? Available
#'   providers can be found with the following command: [oe_providers()]. For
#'   `oe_get()` and `oe_match()`, if `place` is equal to `ITS Leeds`, then
#'   `provider` is set equal to `test`. This is just for simple examples and
#'   internal testings.
#' @param match_by Which column of the provider's database should be used for
#'   matching the input `place` with a `.osm.pbf` file? The default is "name".
#'   Check details and examples in [oe_match()] to understand how this parameter
#'   works. Ignored if `place` is not a character vector since the matching is
#'   performed through a spatial operation.
#' @param max_string_dist Numerical value greater or equal than 0. What is the
#'   maximum distance in fuzzy matching (i.e. Approximate String Distance, see
#'   [adist()]) between input `place` and `match_by` column to tolerate before
#'   asking the user to select which zone to download? This parameter is set
#'   equal to 0 if `match_by` is equal to `iso3166_1_alpha2` or `iso3166_2`.
#'   Check Details and examples in [oe_match()] to understand why this parameter
#'   is important. Ignored if `place` is not a character vector since the
#'   matching is performed through a spatial operation.
#' @param interactive_ask Boolean. If `TRUE` the function creates an interactive
#'   menu in case the best match is further than `max_string_dist`, otherwise it
#'   fails with `stop()`. Check details and examples in [oe_match()] to
#'   understand why this parameter is important. Ignored if `place` is not a
#'   character vector since the matching is performed through a spatial
#'   operation.
#' @param download_directory Where to download the file containing the OSM data?
#'   By default this is equal to [oe_download_directory()], which is equal to
#'   `tempdir()` and it changes each time you restart R. You can set a
#'   persistent `download_directory` by adding the following to your `.Renviron`
#'   file (e.g. with [usethis::edit_r_environ()]):
#'   `OSMEXT_DOWNLOAD_DIRECTORY=/path/to/osm/data`.
#' @param force_download Should the `.osm.pbf` file be updated if it has already
#'   been downloaded? `FALSE` by default. This parameter is used to update old
#'   `.osm.pbf` files.
#' @param max_file_size The maximum file size to download without asking in
#'   interactive mode. Default: `5e+8`, half a gigabyte.
#' @param vectortranslate_options Options to pass to the [`sf::gdal_utils()`]
#'   argument `options`. Set by default. Check Details in the introductory
#'   vignette and in [oe_vectortranslate()].
#' @param osmconf_ini The configuration file specifying which columns should be
#'   in the resulting data frame. See documentation at
#'   [gdal.org](https://gdal.org/drivers/vector/osm.html). Check Details in
#'   [oe_vectortranslate()].
#' @param extra_tags Which addition columns, corresponding to OSM tags,
#'   should be in the resulting dataset? `FALSE` by default. Check Details at
#'   [oe_vectortranslate()] and [oe_get_keys()] .
#' @param force_vectortranslate Boolean. Force the original `.pbf` file to be
#'   translated into a `.gpkg` file, even if a `.gpkg` with the same name
#'   already exists? Check Details at [oe_vectortranslate()] .
#' @param skip_vectortranslate Boolean. If `TRUE` then the function skips all
#'   vectortranslate operations and it reads (or simply returns the path) of
#'   the `.osm.pbf` file. `FALSE` by default.
#' @param quiet Boolean. If `FALSE` the function prints informative messages.
#' @param download_only Boolean. If `TRUE` then the function only returns the
#'   path where the matched file is stored, instead of reading it. `FALSE` by
#'   default.
#' @param ... Arguments that will be passed to [`sf::st_read()`], like `query`
#'   or `stringsAsFactors`.  Check the introductory vignette to understand how
#'   to create your own (SQL-like) queries.
#'
#' @return An sf object.
#' @export
#'
#' @details The algorithm that we use for importing an OSM extract data into R
#'   is divided into 4 steps: 1) Matching the input `place` with the url of a
#'   `.pbf` file; 2) download the `.pbf` file; 3) convert it into `.gpkg` format
#'   and 4) read-in the `.gpkg` file. The function `oe_match()` is used to
#'   perform the first operation and the function `oe_read()` (which is a
#'   wrapper around `oe_download()`, `oe_vectortranslate()` and `sf::st_read()`)
#'   performs the other three operations.
#'
#' @seealso [`oe_match()`], [`oe_download()`], [`oe_vectortranslate()`],
#'   and [`oe_read()`].
#'
#' @examples
#' # Download OSM extracts associated to a simple test.
#' its = oe_get("ITS Leeds", quiet = FALSE)
#' class(its)
#' unique(sf::st_geometry_type(its))
#'
#' # Get another layer from the test extract
#' its_points = oe_get("ITS Leeds", layer = "points")
#' unique(sf::st_geometry_type(its_points))
#'
#' # Get the .osm.pbf and .gpkg file path
#' oe_get("ITS Leeds", download_only = TRUE)
#' oe_get("ITS Leeds", download_only = TRUE, skip_vectortranslate = TRUE)
#'
#' # Add additional tags
#' its_with_oneway = oe_get("ITS Leeds", extra_tags = "oneway", quiet = FALSE)
#' names(its_with_oneway)
#' table(its_with_oneway$oneway)
#'
#' # Use the query argument to get only oneway streets:
#' q = "SELECT * FROM 'lines' WHERE oneway IN ('yes')"
#' its_residential = oe_get("ITS Leeds", query = q)
#' its_residential
#'
#' \dontrun{
#' west_yorkshire = oe_get("West Yorkshire", quiet = FALSE)
#' # If you run it again, the function will not download the file or convert it
#' west_yorkshire = oe_get("West Yorkshire", quiet = FALSE)
#' # match with coordinates (any EPSG)
#' milan_duomo = sf::st_sfc(sf::st_point(c(1514924, 5034552)), crs = 3003)
#' # Warning: the .pbf file is 400MB
#' oe_get(milan_duomo, quiet = FALSE)
#' # match with numeric coordinates (EPSG = 4326)
#' oe_match(c(9.1916, 45.4650), quiet = FALSE)
#' # alternative providers
#' baku = oe_get(place = "Baku", provider = "bbbike", quiet = FALSE)}
oe_get = function(
  place,
  layer = "lines",
  ...,
  provider = "geofabrik",
  match_by = "name",
  max_string_dist = 1,
  interactive_ask = FALSE,
  download_directory = oe_download_directory(),
  force_download = FALSE,
  max_file_size = 5e+8,
  vectortranslate_options = NULL,
  osmconf_ini = NULL,
  extra_tags = NULL,
  force_vectortranslate = FALSE,
  download_only = FALSE,
  skip_vectortranslate = FALSE,
  quiet = TRUE
) {

  # See https://github.com/ITSLeeds/osmextract/pull/125
  if (place == "ITS Leeds") {
    provider = "test"
  }

  # Match the input place with the provider's data.
  matched_zone = oe_match(
    place = place,
    provider = provider,
    match_by = match_by,
    max_string_dist = max_string_dist,
    interactive_ask = interactive_ask,
    quiet = quiet
  )

  # Extract the matched URL and file size and pass these parameters to the
  # osmext-download function.
  file_url = matched_zone[["url"]]
  file_size = matched_zone[["file_size"]]

  oe_read(
    file_path = file_url,
    layer = layer,
    provider = provider,
    download_directory = download_directory,
    file_size = file_size,
    force_download = force_download,
    max_file_size = max_file_size,
    download_only = download_only,
    skip_vectortranslate = skip_vectortranslate,
    vectortranslate_options = vectortranslate_options,
    osmconf_ini = osmconf_ini,
    extra_tags = extra_tags,
    force_vectortranslate = force_vectortranslate,
    quiet = quiet,
    ...
  )

}

