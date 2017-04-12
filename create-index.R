#!/usr/bin/env Rscript

createIndex <- function(path, type) {
	tools::write_PACKAGES(path, type=type)
}

base <- "/repos/cran"
win <- "bin/windows/contrib"
mac <- "bin/macosx/mavericks/contrib"
src <- "src/contrib"
#createIndex(paste(base, win, "3.0", sep = "/"), "win.binary")
#createIndex(paste(base, win, "3.1", sep = "/"), "win.binary")
createIndex(paste(base, win, "3.2", sep = "/"), "win.binary")
createIndex(paste(base, win, "3.3", sep = "/"), "win.binary")
createIndex(paste(base, mac, "3.2", sep = "/"), "mac.binary")
createIndex(paste(base, mac, "3.3", sep = "/"), "mac.binary")
createIndex(paste(base, src, sep = "/"), "source")
