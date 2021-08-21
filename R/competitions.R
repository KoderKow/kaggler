#' Competitions List
#'
#' List competitions
#'
#' @param page Numeric. Page number. Defaults to 1. Required: FALSE.
#' @param search Character. Search terms. Required: FALSE.
#' @export
kgl_competitions_list <- function(page = 1, search = NULL) {
  get_request <- kgl_api_get(
    path = "competitions/list",
    page = page,
    search = search
  )

  kgl_as_tbl(get_request)
}
