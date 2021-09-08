#' Competitions Data List Files
#'
#' List competition data files
#'
#' @param id Character. Competition name.
#' @param clean_response Logical. Clean the response from the Kaggle API. If `FALSE`, this will return the object from the [httr::GET()] call.
#'
#' @return Based on `clean_response`: A tibble containing information on the given `id` or a [httr::GET()] object.
#' @export
#' @family Competitions
#'
kgl_competitions_data_list <- function(id, clean_response = TRUE) {
  if (!assertthat::is.string(id)) {
    usethis::ui_oops("'id' must be a character that references (ref) the competition. This dos not accept the numeric ID.")
    usethis::ui_stop("'id' is not a string.")
  }

  get_url <- glue::glue("competitions/data/list/{id}")

  get_request <- kgl_api_get(get_url)

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

#' CompetitionsDataDownloadFile
#'
#' Download competition data file
#'
#' @inheritParams kgl_competitions_data_list
#' @param file_name Character. Competition name.
#' @param output_dir Character. Directory to save the file.
#'
#' @return An invisible [httr::GET()] object.
#' @export
#' @family Competitions
kgl_competitions_data_download <- function(
  id,
  file_name,
  output_dir = "."
) {
  if (!assertthat::is.string(id)) {
    usethis::ui_oops("'id' must be a character that references (ref) the competition. This dos not accept the numeric ID.")
    usethis::ui_stop("'id' is not a string.")
  }

  if (!fs::file_exists(output_dir)) {
    stop("output_dir does not exist!")
  }

  get_url <- glue::glue("competitions/data/download/{id}/{file_name}")

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

  return(invisible(get_request))
}

#' Download all competition data.
#'
#' Downloads all data into a zip file.
#'
#' @inheritParams kgl_competitions_data_download
#'
#' @return An invisible [httr::GET()] object.
#' @export
#' @family Competitions
kgl_competitions_data_download_all <- function(
  id,
  output_dir = "."
  ) {
  if (!assertthat::is.string(id)) {
    usethis::ui_oops("'id' must be a character that references (ref) the competition. This dos not accept the numeric ID.")
    usethis::ui_stop("'id' is not a string.")
  }

  get_url <- glue::glue("competitions/data/download-all/{id}")

  get_request <- kgl_api_get(get_url)

  if (get_request$status_code != 200) {
    return(invisible(get_request))
  }

  path_output <- fs::path(output_dir, id, ext = "zip")

  get_request %>%
    purrr::pluck("url") %>%
    download.file(
      destfile = path_output,
      quiet = TRUE
    )

  return(invisible(get_request))
}
