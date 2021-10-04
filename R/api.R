## globals
.kaggle_host_url <- "https://www.kaggle.com"
.kaggle_base_url <- "https://www.kaggle.com/api/v1"
.kaggle_competition_url <- "https://www.kaggle.com/c/"
.kgl_dir <- "_kaggle_data"
.kgl_dir_ui <- usethis::ui_value(paste0(.kgl_dir, "/"))

## URL builder
kgl_api_call <- function(path, ...) {
  ## clean path and build url
  url <- paste0(.kaggle_base_url, "/", gsub("^/+|/+$", "", path))

  ## capture dots
  dots <-
    list(...) %>%
    purrr::compact()

  ## if query/params provided as list, unlist
  if (length(dots) == 1L && is.list(dots[[1]])) {
    dots <- dots[[1]]
  }

  ## args must be named!
  if (length(dots) > 0 && (is.null(names(dots)) || any("" %in% names(dots)))) {
    stop(
      "Unnamed arguments were sent to the internal API call builder. ",
      "Query string arguments must be named!"
    )
  }

  ## build query string
  if (length(dots) > 0L) {
    dots <- paste0(names(dots), "=", dots)
    dots <- paste(dots, collapse = "&")
    url <- paste0(url, "?", dots)
  }

  return(url)
}

## for GET requests
kgl_api_get <- function(path, ..., auth = kgl_auth()) {
  get_url <- kgl_api_call(path, ...)

  ## build and make request
  r <- httr::GET(
    url = get_url,
    auth,
    httr::verbose()
  )

  ## check status
  httr::warn_for_status(r)

  ## print message
  if (r$status_code != 200) {
    m <- httr::content(r)
    if ("message" %in% names(m)) {
      usethis::ui_oops("Request failed. Status code: {m$code}. Message: {m$message}.")
    }
  }

  return(r)
}

## for POST requests
kgl_api_post <- function(path, ..., body = NULL) {
  ## build and make request
  r <- httr::POST(kgl_api_call(path, ...), body = body)

  ## check status
  httr::warn_for_status(r)

  ## print message
  if (r[[grep("status", names(r), value = TRUE)]] != 200) {
    m <- httr::content(r)
    if ("message" %in% names(m)) cat(m$message, fill = TRUE)
  }

  ## return data/response
  invisible(r)
}

#' Make requests to Kaggle's API
#'
#' @param endpoint Character. Endpoint to call.
#' @param ... For req_url_query(): Name-value pairs that provide query parameters. Each value must be either length-1 atomic vector or NULL (which is automatically dropped).
#'
#' @return {httr2} response object.
kgl_request <- function(
  endpoint,
  ...
) {
  resp <-
    .kaggle_base_url %>%
    httr2::request() %>%
    httr2::req_headers("Accept" = "application/json") %>%
    httr2::req_user_agent("kaggler (https://github.com/KoderKow/kaggler)") %>%
    kgl_auth() %>%
    httr2::req_url_path_append(endpoint) %>%
    # httr2::req_url_query(...) %>%
    httr2::req_error(body = kgl_error) %>%
    httr2::req_cache(tempdir()) %>%
    httr2::req_perform()

  return(resp)
}

kgl_error <- function(resp) {
  body <- httr2::resp_body_json(resp)

  return(body$message)
}
