library(rhub)

results = check_for_cran(
  platforms = c(
    "debian-gcc-devel",
    "fedora-gcc-devel",
    "ubuntu-gcc-devel",
    "windows-x86_64-devel",
    "macos-highsierra-release-cran"
  )
)

# previous_checks = rhub::list_package_checks(howmany = 1)
# id = previous_checks$group[1]
# group_check = rhub::get_check(id)
# group_check
#
# group_check$cran_summary()
