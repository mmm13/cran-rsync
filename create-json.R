#!/usr/bin/env Rscript

if(!library(jsonlite, logical.return = TRUE, quietly = TRUE, warn.conflicts = FALSE, verbose = FALSE)) {
        stop("jsonlite library can't be loaded. Try installing, and try again.")
}

# Create packages.json, which shows list of all packages
# that internal site shows
#
# This shows how to setup connections:
# https://stat.ethz.ch/R-manual/R-devel/library/base/html/dcf.html
createPackagesJSON <- function(myurl) {
        con <- url(myurl)
        y <- read.dcf(con, all = TRUE)
        close(con)
        my.json <- toJSON(y)
        write(my.json, file = "/repos/cran/packages.json")
}

createPackagesJSON("file:///repos/cran/bin/windows/contrib/3.3/PACKAGES")
