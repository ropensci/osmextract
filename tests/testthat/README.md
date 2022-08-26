NB: ALWAYS REMEMBER TO SET

``` r
withr::local_envvar(
  .new = list(
  "OSMEXT_DOWNLOAD_DIRECTORY" = tempdir(),
  "TESTTHAT" = "true"
  )
)
```

IF YOU NEED TO MODIFY THE `OSMEXT_DOWNLOAD_DIRECTORY` envvar INSIDE THE TESTS. Moreover, the `TESTTHAT` envvar is set equal to `"true"` so that `oe_clean()` always run without an interactive menu (even if I restart the R session). 

NB2: The `withr::local_envvar(...)` must be placed before the `defer()` steps otherwise the temporary envvar are deleted before that step is run. 

We could also set the same option at the beginning of each script, but that makes the debugging more difficult since I have to manually reset the options at the end of the debugging process.

See R/test-helpers.R for more details.

NB3: I don't need to set `withr::defer` when using `setup_pbf()` since that function automatically sets it.
