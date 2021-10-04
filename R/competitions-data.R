#' Competitions Data List Files
#'
#' List competition data files
#'
#' @param id Character. Competition name.
#' @param clean_response Logical. Clean the response from the Kaggle API. If `FALSE`, this will return the object from the [httr2::req_perform()] call.
#'
#' @return Based on `clean_response`
#' - `TRUE`: A tibble containing information on the given `id`
#' - `FALSE`: {httr2} httr2_response object
#' @export
#' @family Competitions
#'
kgl_competitions_data_list <- function(id, clean_response = TRUE) {
  assertthat::assert_that(
    assertthat::is.string(id),
    assertthat::is.flag(clean_response)
  )

  req_url <- glue::glue("competitions/data/list/{id}")

  resp <- kgl_request(
    endpoint = req_url
  )

  if (clean_response == TRUE) {
    resp <-
      resp %>%
      httr2::resp_body_json() %>%
      kgl_as_tbl()
  }

  return(resp)
}

#' Download competition data
#'
#' Download competition data file(s)
#'
#' @inheritParams kgl_competitions_data_list
#' @param file_name Character. Competition name.
#' @param output_dir Character. Directory to save the file.
#' @param clean_response Logical. Download the data within the response from the Kaggle API. If `FALSE`, this will return the object from the [httr2::req_perform()] call.
#'
#' @return An invisible {httr2} httr2_response object.
#' @export
#' @family Competitions
kgl_competitions_data_download <- function(
  id,
  file_name,
  output_dir = ".",
  clean_response = TRUE
) {
  assertthat::assert_that(
    assertthat::is.string(id),
    assertthat::is.string(file_name),
    assertthat::is.string(output_dir),
    assertthat::is.dir(output_dir),
    assertthat::is.flag(clean_response)
  )

  if (!fs::file_exists(output_dir)) {
    stop("output_dir does not exist!")
  }

  req_url <- glue::glue("competitions/data/download/{id}/{file_name}")

  resp <- kgl_request(req_url)

  if (clean_response) {
    path_output <- fs::path(output_dir, file_name)

    if (httr2::resp_content_type(resp) == "text/csv") {
      resp %>%
        httr2::resp_body_string() %>%
        writeBin(path_output)

    } else {
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
  }

  return(invisible(resp))
}

#' Download all competition data.
#'
#' Downloads all data from a competition.
#'
#' @inheritParams kgl_competitions_data_download
#'
#' @return An invisible [httr::GET()] object.
#' @export
#' @family Competitions
kgl_competitions_data_download_all <- function(
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

  req_url <- glue::glue("competitions/data/download-all/{id}")

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

  return(invisible(resp))
}
