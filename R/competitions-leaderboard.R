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
  output_dir = ".",
  clean_response = TRUE
  ) {
  assertthat::assert_that(
    assertthat::is.string(id),
    assertthat::is.string(output_dir),
    assertthat::is.dir(output_dir),
    assertthat::is.flag(clean_response)
  )

  req_url <- glue::glue("competitions/{id}/leaderboard/download")

  resp <- kgl_request(req_url)

  if (clean_response) {
    path_zip <- fs::file_temp(ext = "zip")

    resp %>%
      httr2::resp_body_raw() %>%
      writeBin(path_zip)

    archive::archive_extract(
      archive = path_zip,
      dir = output_dir
    )

    if (fs::file_exists(path_zip)) {
      fs::file_delete(path_zip)
    }
  }

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
  assertthat::assert_that(
    assertthat::is.string(id),
    assertthat::is.flag(clean_response)
  )

  req_url <- glue::glue("competitions/{id}/leaderboard/view")

  resp <- kgl_request(req_url)

  if (clean_response == TRUE) {
    resp <-
      resp %>%
      httr2::resp_body_json() %>%
      kgl_as_tbl()
  }

  return(resp)
}
