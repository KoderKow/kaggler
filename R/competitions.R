#' Competitions List
#'
#' List competitions
#'
#' @param page Numeric. Page number.
#' @param search Character. Search terms.
#' @inheritParams kgl_competitions_data_list
#'
#' @return Based on `clean_response`: A tibble containing information on the given `id` or a [httr::GET()] object.
#' @export
#' @family Competitions
kgl_competitions_list <- function(
  page = 1,
  search = NULL,
  clean_response = TRUE
) {
  get_request <- kgl_api_get(
    path = "competitions/list",
    page = page,
    search = search
  )

  if (get_request$status_code != 200) {
    return(invisible(get_request))
  }

  if (clean_response == TRUE) {
    get_request <-
      get_request %>%
      kgl_as_tbl()
  }

  return(get_request)
}
