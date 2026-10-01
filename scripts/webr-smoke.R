# scripts/webr-smoke.R
# Static smoke test for {webr-r} live cells: every cell must parse as R,
# reference only deployed data files, and use packages from the live set.
# (Full browser execution is covered by manual QA; this runs in CI < 30 s.)

live_pkgs <- c("dplyr", "tidyr", "readr", "stringr", "lubridate",
               "forcats", "tibble", "ggplot2", "knitr")

qmds <- c(list.files(pattern = "\\.qmd$"),
          list.files("appendices", pattern = "\\.qmd$", full.names = TRUE))
stopifnot(length(qmds) > 0)

cells <- 0L
for (f in qmds) {
  lines <- readLines(f, warn = FALSE)
  starts <- grep("^```\\{webr-r\\}$", lines)
  ends <- grep("^```$", lines)
  for (s in starts) {
    e <- ends[ends > s][1]
    stopifnot(!is.na(e))
    code <- paste(lines[(s + 1):(e - 1)], collapse = "\n")
    invisible(parse(text = code)) # fails loudly on syntax errors
    cells <- cells + 1L
    # every data-webr/ reference must exist on disk (deployed via resources)
    for (m in regmatches(code, gregexpr("data-webr/[A-Za-z0-9_.-]+", code))[[1]]) {
      if (!file.exists(m)) stop("missing live data file: ", m, " (from ", f, ")")
    }
    # every library() call must be in the live set
    for (p in regmatches(code, gregexpr("(?<=library\\()[A-Za-z0-9.]+(?=\\))", code, perl = TRUE))[[1]]) {
      if (!p %in% live_pkgs) stop("package not in live set: ", p, " (from ", f, ")")
    }
  }
}
message("webr smoke OK: ", cells, " cells across ", length(qmds), " files")
