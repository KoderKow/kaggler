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
  encoded_params <- url_encode(id)

  endpoint <- glue::glue("/competitions/submissions/list/{encoded_params}")

  resp <- kgl_request(
    endpoint = endpoint,
    page = page
  )

  if (clean_response) {
    resp <-
      resp %>%
      httr2::resp_body_json() %>%
      kgl_as_tbl()
  }

  return(resp)
}

#' Competitions Submissions Url
#'
#' Generate competition submission URL
#'
#' @param id Character.
#' @param file Character. Competition submission file name.
#' @param clean_response Logical.
#'
#' @noRd
kgl_competitions_submissions_url <- function(
  id,
  file
) {
  ## TODO Check if file is a dataset, if it is, prompt user to save it.

  content_length <- file.size(file)

  last_modified_date_utc <-
    file.info(file)$mtime %>%
    lubridate::ymd_hms() %>%
    lubridate::seconds() %>%
    as.integer()

  encoded_params <- url_encode(id)

  endpoint <- glue::glue("competitions/{encoded_params}/submissions/url/{content_length}/{last_modified_date_utc}")

  body <- list(fileName = fs::path_file(file))

  resp <- kgl_request(
    endpoint = endpoint,
    body = body
  ) %>%
    httr2::resp_body_json()

  return(resp)
}

#' Competition Submission Upload
#'
#' Upload competition submission file
#'
#' @param file file, Competition submission file. Required: TRUE.
#' @param guid Character. Location where submission should be uploaded. Required: TRUE.
#'
#' @noRd
kgl_competitions_submissions_upload <- function(
  file,
  create_url
) {
  content_length <- file.size(file)

  last_modified_date_utc <-
    file.info(file)$mtime %>%
    lubridate::ymd_hms() %>%
    lubridate::seconds() %>%
    as.numeric()

  resp <-
    create_url |>
    httr2::request() %>%
    httr2::req_user_agent("kaggler (https://github.com/KoderKow/kaggler)") %>%
    httr2::req_body_file(file) %>%
    httr2::req_method("PUT") |>
    httr2::req_perform() %>%
    httr2::resp_body_json()

  return(resp)
}

#' Competition Submission Submit
#'
#' Submit to competition
#'
#' @param blob_file_tokens Character. Token identifying location of uploaded submission file. Required: TRUE.
#' @param submission_description Character. Description of competition submission. Required: TRUE.
#' @param id Character. Competition name. Required: TRUE.
#'
#' @noRd
kgl_competitions_submissions_submit <- function(
  id,
  blob_file_tokens,
  submission_description
) {
  encoded_params <- url_encode(id)

  endpoint <- glue::glue("competitions/submissions/submit/{encoded_params}")

  body <- list(
    blobFileTokens = blob_file_tokens,
    submissionDescription = submission_description
  )

  resp <- kgl_request(
    endpoint = endpoint,
    body = body
  ) %>%
    httr2::resp_body_json()

  return(resp)
}

#' Submit data to competition
#'
#' @param id Character.
#' @param file Character. Competition submission file name.
#' @param submission_description Character. Description of the submission.
#'
#' @return Nothing.
#' @export
#'
#' @examples
#' \dontrun{
#' kgl_competition_submit(
#'   id = "titanic",
#'   file = "gender_submission.csv",
#'   submission_description = "Trained via rpart"
#' )
#' }
kgl_competition_submit <- function(
  id,
  file,
  submission_description = ""
) {
  url_result <- kgl_competitions_submissions_url(
    id = id,
    file = file
  )

  upload_result <- kgl_competitions_submissions_upload(
    file = file,
    create_url = url_result$createUrl
  )

  submission_result <- kgl_competitions_submissions_submit(
    id = id,
    blob_file_tokens = url_result$token,
    submission_description = submission_description
  )

  usethis::ui_done(submission_result$message)

  return(invisible())
}
