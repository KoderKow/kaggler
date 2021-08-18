#' Competitions List
#'
#' List competitions
#'
#' @param page integer, Page number. Defaults to 1. Required: FALSE.
#' @param search string, Search terms. Required: FALSE.
#' @export
kgl_competitions_list <- function(page = 1, search = NULL) {
  get_request <- kgl_api_get("competitions/list", page = page, search = search)

  kgl_as_tbl(get_request) %>%
    janitor::clean_names()
}
