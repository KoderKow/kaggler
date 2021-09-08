#' Competition Download Leaderboard
#'
#' Download the entire competition leaderboard into a zip file.
#'
#' @inheritParams kgl_competitions_data_download
#'
#' @return An invisible [httr::GET()] object.
#' @export
#' @family Competitions
kgl_competitions_leaderboard_download <- function(
  id,
  output_dir = "."
  ) {
  if (!assertthat::is.string(id)) {
    usethis::ui_oops("'id' must be a character that references (ref) the competition. This dos not accept the numeric ID.")
    usethis::ui_stop("'id' is not a string.")
  }

  get_url <- glue::glue("competitions/{id}/leaderboard/download")

  get_request <- kgl_api_get(get_url)

  if (get_request$status_code != 200) {
    return(invisible(get_request))
  }

  path_output <- fs::path(output_dir, file_name)

  get_request %>%
    purrr::pluck("url") %>%
    download.file(
      destfile = path_output,
      quiet = TRUE
    )

  return(get_request)
}

#' Competition view leaderboard
#'
#' View the top 50 positions in a competition's leaderboard.
#'
#' @inheritParams kgl_competitions_data_list
#'
#' @return Based on `clean_response`: A tibble containing information on the given `id` or a [httr::GET()] object.
#' @export
#' @family Competitions
kgl_competitions_leaderboard_view <- function(
  id,
  clean_response = TRUE
) {
  if (!assertthat::is.string(id)) {
    usethis::ui_oops("'id' must be a character that references (ref) the competition. This dos not accept the numeric ID.")
    usethis::ui_stop("'id' is not a string.")
  }

  get_url <- glue::glue("competitions/{id}/leaderboard/view")

  get_request <- kgl_api_get(get_url)

  if (clean_response == TRUE) {
    get_request <-
      get_request %>%
      kgl_as_tbl()
  }

  return(get_request)
}
