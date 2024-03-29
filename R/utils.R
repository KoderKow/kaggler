## ----------------------------------------------------------------------------##
##                                  WRANGLING                                 ##
## ----------------------------------------------------------------------------##

#' Convert kaggle output to tibble
#'
#' Convert kaggle response objects into informative tibbles
#'
#' @param x Output from kaggle function
#' @return Print out of summary info and a tibble of the data.
kgl_as_tbl <- function(x) {
  d <-
    x %>%
    purrr::map_dfr(~ .x %||% NA) %>%
    tibble::as_tibble(
      .name_repair = snakecase::to_snake_case
    )

  if (nrow(d) > 0) {
    d <- readr::type_convert(d, col_types = readr::cols())
  }

  return(d)
}

url_encode <- function(...) {
  list(...) %>%
    purrr::map_chr(as.character) %>%
    purrr::map_chr(utils::URLencode, reserved = TRUE) %>%
    stringr::str_c(collapse = "/")
}

#' Flatten list and keep names
#'
#' @param x List.
#' @param use.names Logical. Should the names of x be kept?
#' @param classes Character. Vector of class names, or "ANY" to match any class.
#'
#' @return Flattened named list.
#' @references https://stackoverflow.com/questions/49252400/r-purrr-flatten-list-of-named-lists-to-list-and-keep-names
#'
#' @noRd
flatten <- function(x, use.names = TRUE, classes = "ANY") {
  len <- sum(rapply(x, function(x) 1L, classes = classes))
  y <- vector("list", len)
  i <- 0L
  env <- environment()

  items <- rapply(
    object = x,
    f = function(.x) {
      i <- get("i", envir = env)
      i <- i + 1
      assign("i", i, envir = env)

      y <- get("y", envir = env)
      y[[i]] <- .x
      assign("y", y, envir = env)

      TRUE
    },
    classes = classes
  )

  if (use.names && !is.null(nm <- names(items))) {
    names(y) <- snakecase::to_snake_case(nm)
  }

  return(y)
}

"%||%" <- function(x, y) {
  if (is.null(x)) {
    y
  } else {
    x
  }
}

parse_datetimes <- function(x) {
  x[grep("deadline|date", names(x), ignore.case = TRUE)] <- lapply(
    x[grep("deadline|date", names(x), ignore.case = TRUE)],
    parse_datetime
  )
  x
}

parse_datetime <- function(x) {
  # as.POSIXct(strptime(x, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"), tz = "UTC")
  lubridate::ymd_hms(x, tz = "UTC")
}

as_parsed <- function(x) httr::content(x)

as_json <- function(r) {
  jsonlite::fromJSON(httr::content(
    r,
    as = "text",
    encoding = "UTF-8"
  ))
}

readlines <- function(x, ...) {
  con <- file(x)
  x <- readLines(con, warn = FALSE, encoding = "UTF-8", ...)
  close(con)
  x
}

shh <- function(x) {
  suppressMessages(suppressWarnings(x))
}

## ----------------------------------------------------------------------------##
##                              OBJECT VALIDATION                             ##
## ----------------------------------------------------------------------------##

is_recursive <- function(x) vapply(x, is.recursive, logical(1))

validator_param_id <- function(id) {
  if (!assertthat::is.string(id)) {
    usethis::ui_oops("{usethis::ui_value('id')} must be a character that references the competition. Check the docs for {usethis::ui_value('kgl_flow()')} for an acceptable {usethis::ui_value('id')}.")

    return(invisible())
  }
}

validator_competition_id <- function(competition_id) {
  get_url <- glue::glue("competitions/data/list/{competition_id}")

  get_request <- suppressMessages(kgl_api_get(get_url))

  if (get_request$status_code != 200) {
    stop("Invalid competition ID input.")
  }

  return(invisible())
}

validator_rules <- function(competition_id, file_name) {
  get_url <- glue::glue("competitions/data/download/{competition_id}/{file_name}")

  get_request <- kgl_api_get(get_url)

  if (get_request$status_code != 200) {
    competition_url <- glue::glue("{.kaggle_competition_url}{competition_id}/rules")
    competition_url_ui <- usethis::ui_value(competition_url)
    user_check <- usethis::ui_yeah("Would you like to visit {competition_url_ui} to accept the rules?")

    if (user_check) {
      browseURL(competition_url)
    }

    usethis::ui_todo("Rerun {usethis::ui_value('kgl_flow()')} once the rules are accepted!")

    v_result <- FALSE
  } else {
    v_result <- TRUE
  }

  return(v_result)
}

validator_api_key <- function() {
  # kgl_auth()
  resp <- kgl_request(
    endpoint = "competitions/list",
    search = "titanic"
  )

  if (resp$status_code != 200) {
    kgl_auth_ui <- usethis::ui_value("?kgl_auth()")

    msg <- glue::glue("Request failed. Please make sure you have correctly setup your Kaggle API Key Type {kgl_auth_ui} for more information.")

    stop(msg)
  }
}

## ----------------------------------------------------------------------------##
##                                RENVIRON FUNS                               ##
## ----------------------------------------------------------------------------##


set_renv <- function(...) {
  dots <- list(...)
  stopifnot(are_named(dots))
  vars <- names(dots)
  x <- paste0(names(dots), "=", dots)
  x <- paste(x, collapse = "\n")
  for (var in vars) {
    check_renv(var)
  }
  append_lines(x, file = .Renviron())
  readRenviron(.Renviron())
}

check_renv <- function(var = NULL) {
  if (!file.exists(.Renviron())) {
    return(invisible())
  }
  if (is_incomplete(.Renviron())) {
    append_lines("", file = .Renviron())
  }
  if (!is.null(var)) {
    clean_renv(var)
  }
  invisible()
}

.Renviron <- function() {
  if (file.exists(".Renviron")) {
    ".Renviron"
  } else {
    file.path(home(), ".Renviron")
  }
}

is_incomplete <- function(x) {
  con <- file(x)
  x <- tryCatch(readLines(con, encoding = "UTF-8"), warning = function(w) {
    return(TRUE)
  })
  close(con)
  ifelse(isTRUE(x), TRUE, FALSE)
}

has_name_ <- function(x, name) isTRUE(name %in% names(x))

define_args <- function(args, ...) {
  dots <- list(...)
  nms <- names(dots)
  for (i in nms) {
    if (!has_name_(args, i)) {
      args[[i]] <- dots[[i]]
    }
  }
  args
}

home <- function() {
  if (!identical(Sys.getenv("HOME"), "")) {
    file.path(Sys.getenv("HOME"))
  } else {
    file.path(normalizePath("~"))
  }
}

append_lines <- function(x, ...) {
  args <- define_args(
    c(x, list(...)),
    append = TRUE,
    fill = TRUE
  )
  do.call("cat", args)
}

clean_renv <- function(var) {
  x <- readlines(.Renviron())
  x <- grep(sprintf("^%s=", var), x, invert = TRUE, value = TRUE)
  writeLines(x, .Renviron())
}

are_named <- function(x) is_named(x) && !"" %in% names(x)

is_named <- function(x) !is.null(names(x))

## Console display
ui_ul <- function(x) {
  x %>%
    purrr::map_chr(~ {
      paste0("- ", usethis::ui_value(.x))
    }) %>%
    glue::glue_collapse("\n")
}
