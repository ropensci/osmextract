#' @keywords internal
"_PACKAGE"

# The following block is used by usethis to automatically manage
# roxygen namespace tags. Modify with care!
## usethis namespace: start
## usethis namespace: end
NULL

# nocov start

# Adds additional question to devtools::release(). See Details section in
# ?devtools::release()
release_questions = function() {
  c("Did you check that the original osmconf.ini file was not updated?")
}

# Adds additional bullet points to usethis::use_release_issue()
release_bullets = function() {
  c(
    "Update database for the providers"
  )
}

# nocov end
