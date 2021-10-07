#' DatasetsList
#'
#' List datasets
#'
#' @param page Numeric. Page number. Defaults to 1. Retrieve datasets via page, search, or (ownerSlug and datasetSlug)
#' @param search Character. Search terms. Defaults to . Retrieve datasets via page, search, or (ownerSlug and datasetSlug)
#' @param owner_dataset Character. Alternative to page/search.  The owner and dataset slug as it appears in the URL, i.e., \code{"mathan/fifa-2018-match-statistics"}.
#'
#' @family Datasets
kgl_datasets_list <- function(
  page = 1,
  search = NULL,
  owner_dataset = NULL
) {
  assertthat::assert_that(
    assertthat::is.number(page),
    is.null(search) || assertthat::is.string(search),
    is.null(owner_dataset) || assertthat::is.string(owner_dataset)
  )

  if (!is.null(owner_dataset)) {
    owner_dataset_clean <- owner_dataset_parser(owner_dataset)
    owner_slug <- owner_dataset_clean[1]
    dataset_slug <- owner_dataset_clean[2]

    get_url <- glue::glue("datasets/list/{owner_slug}/{dataset_slug}")

    get_request <- kgl_api_get(get_url)
  } else {
    get_request <- kgl_api_get(
      path = "datasets/list",
      page = page,
      search = search
    )

    resp <- kgl_request(
      endpoint = "datasets/list",
      page = page,
      search = search
    )
  }

  if (clean_response) {
    l_raw <-
      resp %>%
      httr2::resp_body_json()

    d <-
      l_raw %>%
      purrr::map_dfr(~ {
        purrr::keep(.x, ~ class(.x) != "list")
      }) %>%
      kgl_as_tbl()

    tags <-
      l_raw %>%
      purrr::set_names(d$id) %>%
      purrr::map("tags") %>%
      purrr::imap_dfr(~ {
        .x %>%
          dplyr::bind_rows() %>%
          dplyr::mutate(id = .y) %>%
          dplyr::relocate(id)
      })

    files <-
      l_raw %>%
      purrr::set_names(d$id) %>%
      purrr::map("files")

    versions <-
      l_raw %>%
      purrr::set_names(d$id) %>%
      purrr::map("versions")

    resp <- list(
      datasets = d,
      tags = tags,
      files = files,
      versions = versions
    )
  }

  resp
}

owner_dataset_parser <- function(owner_dataset) {
  kaggle_pattern <- paste0("^", .kaggle_host_url, "/")
  if (stringr::str_detect(owner_dataset, kaggle_pattern)) {
    owner_dataset <-
      owner_dataset %>%
      stringr::str_remove(kaggle_pattern)
  }

  owner_dataset <- strsplit(owner_dataset, "/")[[1]]

  return(owner_dataset)
}

#' Datasets View
#'
#' Show details about a dataset
#'
#' @param owner_dataset Character. The owner and data set slug as it appears in the URL, i.e., \code{"mathan/fifa-2018-match-statistics"}.
#'
#' @family Datasets
kgl_datasets_view <- function(owner_dataset) {
  owner_dataset_clean <- owner_dataset_parser(owner_dataset)
  owner_slug <- owner_dataset_clean[1]
  dataset_slug <- owner_dataset_clean[2]

  get_url <- glue::glue("datasets/view/{owner_slug}/{dataset_slug}")
  get_request <- kgl_api_get(get_url)

  kgl_as_tbl(get_request)
}

#' DatasetsDownloadFile
#'
#' Download dataset file
#'
#' @param owner_dataset The owner and data set slug as it appears in the URL,
#'   i.e., \code{"mathan/fifa-2018-match-statistics"}.
#' @param fileName string, File name. Required: TRUE.
#' @param datasetVersionNumber string, Dataset version number. Required: FALSE.
#' @family Datasets
kgl_datasets_download <- function(
  owner_dataset,
  fileName,
  datasetVersionNumber = NULL
) {
  owner_dataset_clean <- owner_dataset_parser(owner_dataset)
  owner_slug <- owner_dataset_clean[1]
  dataset_slug <- owner_dataset_clean[2]

  kgl_api_get(
    glue::glue(
      "datasets/download/{ownerSlug}/{datasetSlug}/{fileName}"
    ),
    datasetVersionNumber = datasetVersionNumber
  )
}

#' DatasetsUploadFile
#'
#' Get URL and token to start uploading a data file
#'
#' @param fileName string, Dataset file name. Required: TRUE.
#' @param contentLength integer, Content length of file in bytes. Required: TRUE.
#' @param lastModifiedDateUtc integer, Last modified date of file in milliseconds
#'   since epoch in UTC. Required: TRUE.
#' @family Datasets
kgl_datasets_upload_file <- function(
  fileName,
  contentLength,
  lastModifiedDateUtc
) {
  contentLength <- file.size(fileName)
  lastModifiedDateUtc <- format(
    file.info(fileName)$mtime,
    format = "%Y-%m-%d %H-%M-%S",
    tz = "UTC"
  )
  kgl_api_post(
    glue::glue(
      "datasets/upload/file/{contentLength}/{lastModifiedDateUtc}"
    ),
    fileName = fileName
  )
}

#' DatasetsCreateVersion
#'
#' Create a new dataset version
#'
#' @param owner_dataset The owner and data set slug as it appears in the URL,
#'   i.e., \code{"mathan/fifa-2018-match-statistics"}.
#' @param datasetNewVersionRequest Information for creating a new dataset version.
#'   Required: TRUE.
#' @family Datasets
kgl_datasets_create_version <- function(
  owner_dataset,
  datasetNewVersionRequest
) {
  owner_dataset_clean <- owner_dataset_parser(owner_dataset)
  owner_slug <- owner_dataset_clean[1]
  dataset_slug <- owner_dataset_clean[2]

  kgl_api_post(
    glue::glue(
      "datasets/create/version/{ownerSlug}/{datasetSlug}"
    ),
    datasetNewVersionRequest = datasetNewVersionRequest
  )
}

#' DatasetsCreateNew
#'
#' Create a new dataset
#'
#' @param datasetNewRequest Information for creating a new dataset. Required: TRUE.
#' @family Datasets
kgl_datasets_create_new <- function(datasetNewRequest) {
  kgl_api_post("datasets/create/new", datasetNewRequest = datasetNewRequest)
}
