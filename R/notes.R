
#' Update 'daily.md' file from new 'calcurse' TODO notes
#'
#' @param quiet If 'TRUE', display information about file locations and
#' statuses.
#' @return (Invisibly) TRUE if 'daily.md' in the path specified by
#' 'CALCURSE_DIR' is updated, otherwise FALSE.
#' @export
cc_update_notes <- function (quiet = FALSE) {

    f_daily <- file.path (cc_dir (), "daily.md")
    if (!file.exists (f_daily)) {
        stop ("No 'daily.md' file found")
    }

    daily <- brio::read_lines (f_daily)
    notes <- read_notes ()
    notes <- cache_notes (notes)

    msg <- "No updates to 'daily.md'"
    ret <- !is.null (notes)

    if (ret) {

        d_old <- daily
        daily <- add_notes_to_daily (notes, daily)
        ret <- !identical (d_old, daily)

        if (ret) {
            brio::write_lines (daily, f_daily)
            msg <- paste0 ("daily.md at [", cc_dir (), "] file updated")
        }
    }

    if (!quiet) {
        message (msg)
    }

    invisible (ret)
}

read_notes <- function () {

    todo <- brio::read_lines (file.path (calcurse_dir (), "todo"))
    # Get any notes:
    hashes <- regexpr (">.*\\s", todo)
    has_hash <- which (hashes > 0)
    hashes <- gsub ("^>|\\s.*$", "", regmatches (todo, hashes))

    todo <- gsub ("^\\S*\\s", "", todo [has_hash])

    notes <- list.files (file.path (calcurse_dir (), "notes"),
                         recursive = TRUE,
                         full.names = TRUE)
    notes <- notes [grep (paste0 (hashes, collapse = "|"), notes)]

    notes <- lapply (notes, brio::read_lines)
    names (notes) <- todo

    # Find notes with markdown items:
    index <- which (vapply (notes, function (n)
                            any (grepl ("^\\-\\s\\[(x|\\s)\\]", n)),
                            logical (1)))
    notes <- lapply (notes [index], function (n) {
                index <- grep ("[0-9]*\\/[0-9]*\\/[0-9]*\\s", n)
                n_i <- n [index]
                dates <- regmatches (n_i,
                            regexpr ("[0-9]*\\/[0-9]*\\/[0-9]*", n_i))
                dates <- as.Date (strptime (dates, "%d/%m/%Y"))
                wdays <- as.character (
                    lubridate::wday (dates, label = TRUE, abbr = TRUE)
                    )
                d_fmt <- strftime (dates, "%d/%m/%Y")
                d_fmt <- paste0 ("**", wdays, " ", d_fmt, "**")

                n_i <- gsub ("^\\-\\s\\[.\\]\\s[0-9]*\\/[0-9]*\\/[0-9]*\\s",
                             "", n_i)
                data.frame (date = dates, d_fmt = d_fmt, content = n_i)
                         })

    for (n in seq_along (notes)) {
        notes [[n]]$title <- names (notes) [n]
    }

    return (notes)
}

cache_notes <- function (notes) {

    cc_dir <- calcurse_dir ()
    f <- file.path (cc_dir, "notes-hash")
    hash_old <- NULL
    if (file.exists (f)) {
        hash_old <- brio::read_lines (f)
    }
    hash_new <- digest::digest (notes)

    if (identical (hash_new, hash_old)) {
        notes <- NULL
    } else {
        brio::write_lines (hash_new, f)
    }

    return (notes)
}

add_notes_to_daily <- function (notes, daily) {

    notes <- do.call (rbind, notes)
    notes <- notes [order (notes$date, decreasing = TRUE), ]

    # add new dates to daily
    index <- which (!notes$d_fmt %in% daily)
    if (length (index) > 0L) {
        daily <- add_new_dates (notes$date [index], daily)
    }

    notes <- split (notes, f = as.factor (notes$date))

    index_dates <- grep ("^\\*\\*", daily)
    for (n in notes) {
        index <- match (n$d_fmt [1], daily) + 1
        index_next <- index_dates [which (index_dates > index)] [1]

        index_head <- seq (index)
        index_tail <- index_next:length (daily)
        index_day <- seq (length (daily)) [-c (index_head, index_tail)]

        daily_head <- daily [index_head]
        daily_day <- daily [index_day]
        daily_tail <- daily [index_tail]

        n_i <- paste0 ("- [ ] ", n$title, ": ", n$content)
        n_i <- n_i [which (!n_i %in% daily_day)]
        daily_day <- c (daily_day, n_i, "")

        daily <- c (daily_head, daily_day, daily_tail)
    }

    return (daily)
}
