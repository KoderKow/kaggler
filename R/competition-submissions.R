#' CompetitionsSubmissionsUrl
#'
#' Generate competition submission URL
#'
#' @param file_name string, Competition submission file name. Required: FALSE.
#'   since epoch in UTC. Required: TRUE.
#' @export
kgl_competitions_submissions_url <- function(file_name = NULL) {
  content_length <- file.size(file_name)

  last_modified_date_utc <- format(
    x = file.info(file_name)$mtime,
    format = "%Y-%m-%d %H-%M-%S",
    tz = "UTC"
  )

  post_url <- glue::glue("competitions/submissions/url/{content_length}/{last_modified_date_utc}")

  kgl_api_post(
    post_url,
    fileName = file_name
  )
}

#' CompetitionsSubmissionsUpload
#'
#' Upload competition submission file
#'
#' @param file file, Competition submission file. Required: TRUE.
#' @param guid string, Location where submission should be uploaded. Required: TRUE.
#'
#' @export
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

#' CompetitionsSubmissionsSubmit
#'
#' Submit to competition
#'
#' @param blob_file_tokens string, Token identifying location of uploaded submission
#'   file. Required: TRUE.
#' @param submission_description string, Description of competition submission.
#'   Required: TRUE.
#' @param id string, Competition name. Required: TRUE.
#' @export
kgl_competitions_submissions_submit <- function(
  blob_file_tokens,
  submission_description,
  id
) {
  competition_id <- id_type_guesser(id)

  post_url <- glue::glue("competitions/submissions/submit/{competition_id}")

  kgl_api_post(
    post_url,
    blobFileTokens = blob_file_tokens,
    submissionDescription = submission_description
  )
}
