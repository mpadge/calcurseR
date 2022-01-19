calcurse_dir <- function () {
    d <- Sys.getenv ("CALCURSE_DIR")
    if (!nzchar (d)) {
        stop ("This package requires an environment variable [",
              "CALCURSE_DIR] to be set")
    }
    return (d)
}

daily_dir <- function () {
    Sys.getenv ("DAILY_DIR")
}
