#' Competitions List
#'
#' List competitions
#'
#' @param page Numeric. Page number.
#' @param search Character. Search terms.
#' @inheritParams kgl_competitions_data_list
#'
#' @return Based on `clean_response`
#' - `TRUE`: A tibble containing information on the given `id`
#' - `FALSE`: {httr2} httr2_response object
#' @export
#' @family Competitions
kgl_competitions_list <- function(
  page = 1,
  search = NULL,
  clean_response = TRUE
) {
  assertthat::assert_that(
    assertthat::is.number(page),
    is.null(search) || assertthat::is.string(search),
    assertthat::is.flag(clean_response)
    )

  resp <- kgl_request(
    endpoint = "competitions/list",
    page = page,
    search = search
  )

  if (clean_response == TRUE) {
    resp <-
      resp %>%
      httr2::resp_body_json() %>%
      kgl_as_tbl()
  }

  return(resp)
}
