
#' Update 'daily.md' file with new 'calcurse' entries
#'
#' @param quiet If 'TRUE', display information about file locations and statuses.
#' @return (Invisibly) TRUE if 'daily.md' in the path specified by
#' 'CALCURSE_DIR' is updated, otherwise FALSE.
#' @export
cc_update_daily <- function (quiet = FALSE) {

    f_daily <- file.path (cc_dir (), "daily.md")
    daily <- NULL
    if (file.exists (f_daily)) {
        daily <- brio::read_lines (f_daily)
    }

    apts <- read_apts ()
    ret <- length (apts) > 0L

    msg <- "No updates to 'daily.md'"

    if (ret) {
        dates <- regmatches (apts, regexpr ("[0-9]+\\/[0-9]+\\/[0-9]+{2}", apts))
        d <- as.Date (strptime (dates, "%m/%d/%Y"))
        daily <- add_new_dates (d, daily)
        daily <- add_new_apts (apts, daily)

        brio::write_lines (daily, f_daily)

        msg <- paste0 ("daily.md at [", cc_dir (), "] file updated")
    }

    if (!quiet) {
        message (msg)
    }

    invisible (ret)
}

read_apts <- function (regular = FALSE) {

    apts <- brio::read_lines (file.path (calcurse_dir (), "apts"))
    if (!regular) {
        apts <- apts [-grep ("\\{[0-9]W\\}", apts)]
    }
    f_cache <- file.path (calcurse_dir (), "calcurse-cache")
    apts_cache <- NULL
    if (file.exists (f_cache)) {
        apts_cache <- brio::read_lines (f_cache)
    }

    brio::write_lines (apts, f_cache)

    if (any (apts %in% apts_cache)) {
        apts <- apts [-which (apts %in% apts_cache)]
    }

    return (apts)
}

add_new_dates <- function (d, daily) {

    if (length (d) == 0L) {
        return (daily)
    }

    # add any new dates from calendar:
    daily_dates <- gsub ("\\*\\*", "", grep ("^\\*\\*", daily, value = TRUE))
    daily_dates <- as.Date (strptime (gsub ("^\\w+\\s", "", daily_dates), "%d/%m/%Y"))

    dnew <- unique (d [which (d > max (daily_dates))])
    if (length (dnew) == 0L) {
        return (daily)
    }

    today <- as.Date (strftime (Sys.time (), "%Y-%m-%d"))
    dnew <- rev (seq (today, max (dnew), by = "days") [-1])
    dnew_abbr <- as.character (lubridate::wday (dnew, label = TRUE, abbr = TRUE))
    dnew <- strftime (dnew, "%d/%m/%Y")
    index <- which (!dnew_abbr %in% c ("Sat", "Sun"))
    dnew <- dnew [index]
    dnew_abbr <- dnew_abbr [index]
    dnew <- paste0 ("**", dnew_abbr, " ", dnew, "**")
    n <- length (dnew)
    dnew <- rep (dnew, each = 2)
    dnew [seq (n) * 2] <- ""

    index <- 1:grep ("^\\#\\#\\#", daily) [1] - 1
    daily <- c (daily [index],
                dnew,
                daily [-index])

    return (daily)
}

add_new_apts <- function (apts, daily) {

    if (length (apts) == 0L) {
        return (daily)
    }

    dates <- regmatches (apts, regexpr ("[0-9]+\\/[0-9]+\\/[0-9]+{2}", apts))
    d <- as.Date (strptime (dates, "%m/%d/%Y"))
    wdays <- as.character (lubridate::wday (d, label = TRUE, abbr = TRUE))
    d <- paste0 ("**", wdays, " ", strftime (d, "%d/%m/%Y"), "**")

    content <- gsub ("^\\|", "", regmatches (apts, regexpr ("\\|.*$", apts)))
    # Get any notes:
    hashes <- regexpr ("[^\\-]>.*\\|", apts)
    has_hash <- which (hashes > 0)
    hashes <- gsub ("^.>|\\s?\\S$", "", regmatches (apts, hashes))
    notes <- vapply (hashes, function (h) {
                         f_h <- file.path ("~/.local/share/calcurse/notes", h)
                         if (!file.exists (f_h)) {
                             return ("")
                         }
                         paste0 (brio::read_lines (f_h), collapse = "\n")
                }, character (1), USE.NAMES = FALSE)
    content [has_hash] <- paste (content [has_hash], notes)

    x <- split (data.frame (date = d, content = content),
                f = as.factor (d))
    for (i in x) {
        j <- which (daily == i$date [1])
        daily <- c (daily [seq (j)],
                    "",
                    paste0 ("- [ ] ", i$content),
                    daily [-seq (j)])
    }

    return (daily)
}
