
#' Competition Download Leaderboard
#'
#' Download competition leaderboard
#'
#' @param id Character. Competition name. Required: TRUE.
#' @export
kgl_competitions_leaderboard_download <- function(id) {
  if (!assertthat::is.string(id)) {
    usethis::ui_oops("'id' must be a character that references (ref) the competition. This dos not accept the numeric ID.")
    usethis::ui_stop("'id' is not a string.")
  }

  competition_id <- id_type_guesser(id)

  get_url <- glue::glue("competitions/{competition_id}/leaderboard/download")

  get_request <- kgl_api_get(get_url)

  return(get_request)
}

#' Competition View Leaderboard
#'
#' VIew competition leaderboard
#'
#' @param id Character. Competition name. Required: TRUE.
#' @export
kgl_competitions_leaderboard_view <- function(id) {
  if (!assertthat::is.string(id)) {
    usethis::ui_oops("'id' must be a character that references (ref) the competition. This dos not accept the numeric ID.")
    usethis::ui_stop("'id' is not a string.")
  }

  competition_id <- id_type_guesser(id)

  get_url <- glue::glue("competitions/{competition_id}/leaderboard/view")

  d_final <-
    get_url %>%
    kgl_api_get() %>%
    kgl_as_tbl() %>%
    dplyr::mutate(score = as.numeric(score))

  return(d_final)
}
