
#' Open 'daily.md' file
#'
#' @return Nothing (opens file for editing and viewing).
#' @export
cc_edit_daily <- function () {

    f_daily <- file.path (cc_dir (), "daily.md")
    if (!file.exists (f_daily)) {
        stop ("No 'daily.md' file found")
    }

    setwd (cc_dir ())
    system2 ("vim", "daily.md")
}
