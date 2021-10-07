#' List competition submissions
#'
#' @inheritParams kgl_competitions_data_list
#' @inheritParams kgl_competitions_list
#'
#' @return Based on `clean_response`
#' - `TRUE`: A tibble containing information on the given `id`
#' - `FALSE`: {httr2} httr2_response object
#' @export
#' @family Competitions
kgl_competitions_list_submissions <- function(
  id,
  page = 1,
  clean_response = TRUE
) {
  req_url <- glue::glue("/competitions/submissions/list/{id}")

  resp <- kgl_request(req_url, page = page)

  if (clean_response) {
    resp <-
      resp %>%
      httr2::resp_body_json() %>%
      kgl_as_tbl()
  }

  return(resp)
}

#' CompetitionsSubmissionsUrl
#'
#' Generate competition submission URL
#'
#' @param file Character. Competition submission file name. Required: FALSE.
#'   since epoch in UTC. Required: TRUE.
kgl_competitions_submissions_url <- function(file = NULL) {
  content_length <- file.size(file)

  last_modified_date_utc <-
    file.info(file)$mtime %>%
    lubridate::ymd_hms() %>%
    lubridate::seconds() %>%
    as.numeric() * 1e3

  last_modified_date_utc <- "2021-10-06T06:28:48.202Z"

  req_url <- glue::glue("competitions/{id}/submissions/url/{content_length}/{last_modified_date_utc}")

  resp <- kgl_request(
    endpoint = req_url,
    body = list(
      fileName =  fs::path_file(file)
    )
  )
}

#' Competition Submission Upload
#'
#' Upload competition submission file
#'
#' @param file file, Competition submission file. Required: TRUE.
#' @param guid Character. Location where submission should be uploaded. Required: TRUE.
kgl_competitions_submissions_upload <- function(file, guid) {
  content_length <- file.size(file)

  last_modified_date_utc <- format(
    x = file.info(file)$mtime,
    format = "%Y-%m-%d %H-%M-%S",
    tz = "UTC"
  )

  post_url <- glue::glue("competitions/submissions/upload/{guid}/{content_length}/", "{last_modified_date_utc}")

  kgl_api_post(
    post_url,
    body = httr::upload_file(file)
  )
}

#' Competition Submission Submit
#'
#' Submit to competition
#'
#' @param blob_file_tokens Character. Token identifying location of uploaded submission file. Required: TRUE.
#' @param submission_description Character. Description of competition submission. Required: TRUE.
#' @param id Character. Competition name. Required: TRUE.
kgl_competitions_submissions_submit <- function(
  blob_file_tokens,
  submission_description,
  id
) {
  post_url <- glue::glue("competitions/submissions/submit/{id}")

  kgl_api_post(
    post_url,
    blobFileTokens = blob_file_tokens,
    submissionDescription = submission_description
  )
}
