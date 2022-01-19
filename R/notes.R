
#' Update 'daily.md' file from new 'calcurse' TODO notes
#'
#' @param quiet If 'TRUE', display information about file locations and statuses.
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
    if (is.null (notes)) {
        return (NULL)
    }
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
                dates <- regmatches (n_i, regexpr ("[0-9]*\\/[0-9]*\\/[0-9]*", n_i))
                dates <- as.Date (strptime (dates, "%d/%m/%Y"))
                wdays <- as.character (lubridate::wday (dates, label = TRUE, abbr = TRUE))
                d <- paste0 ("**", wdays, " ", dates, "**")

                n_i <- gsub ("^\\-\\s\\[.\\]\\s[0-9]*\\/[0-9]*\\/[0-9]*\\s",
                             "", n_i)
                data.frame (date = dates, d_fmt = d, content = n_i)
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
