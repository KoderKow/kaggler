#' Competitions Data List Files
#'
#' List competition data files
#'
#' @param id Character. Competition name. This accepts 3 formats. Based on the input, the function will try to obtain the correct compeition ID.
#' - The competition's URL
#'   - Checks to see if string start with `https://`
#' - Kaggle API command from the data tab
#'   - Checks to see if string starts with `kaggle competitions `
#' - Direct Competition ID/Name
#'   - If the two checks above fail, the function will interpret the string as is
#' @param clean_response Logical. Clean the response from the Kaggle API.
#'
#' @export
kgl_competitions_data_list <- function(id, clean_response = TRUE) {
  if (!assertthat::is.string(id)) {
    usethis::ui_oops("'id' must be a character that references (ref) the competition. This dos not accept the numeric ID.")
    usethis::ui_stop("'id' is not a string.")
  }

  competition_id <- id_type_guesser(id)

  get_url <- glue::glue("competitions/data/list/{competition_id}")

  get_request <- kgl_api_get(get_url)

  if (clean_response == TRUE) {
    get_request <-
      get_request %>%
      kgl_as_tbl() %>%
      dplyr::mutate(id = competition_id) %>%
      dplyr::relocate(id)
  }

  return(get_request)
}

#' CompetitionsDataDownloadFile
#'
#' Download competition data file
#'
#' @inheritParams kgl_competitions_data_list
#' @param file_name Character. Competition name. Required: TRUE.
#' @param return_data Logical. Read in the data with `readr::read_csv()` and have it returned. If `FALSE` this will return `NULL`.
#' @param save_data Logical. Save the data in `dir_name`. If `FALSE` this will remove the `dir_name` directory.
#' @param dir_name Character. Name of the directory to make to store data.
#' @param quiet Logical. Silence output from `download.file()`.
#' @export
kgl_competitions_data_download <- function(
  id,
  file_name,
  return_data = TRUE,
  save_data = TRUE,
  dir_name = "_kaggle_data",
  quiet = TRUE
) {
  if (!assertthat::is.string(id)) {
    usethis::ui_oops("'id' must be a character that references (ref) the competition. This dos not accept the numeric ID.")
    usethis::ui_stop("'id' is not a string.")
  }

  competition_id <- id_type_guesser(id)

  get_url <- glue::glue("competitions/data/download/{competition_id}/{file_name}")

  get_request <- kgl_api_get(get_url)

  if (httr::status_code(get_request) != 200) {
    return(invisible(NULL))
  }

  ## create temp dir
  dir_kaggle <- usethis::proj_path(dir_name)
  dir_value <- usethis::ui_value(paste0(dir_kaggle, "/"))

  if (!fs::dir_exists(usethis::proj_path(dir_name))) {
    usethis::ui_info("Data directory {dir_value} has been created!")
    fs::dir_create(dir_kaggle)
  }

  get_url <- get_request$url

  get_ext <- fs::path_ext(get_url)

  path_temp <- fs::path(
    dir_kaggle,
    file_name,
    ext = ifelse(get_ext == "zip", "zip", "")
  )

  file_name_value <- usethis::ui_value(file_name)
  usethis::ui_todo("Downloading {file_name_value}...")

  download.file(
    url = get_url,
    destfile = path_temp,
    mode = "wb",
    quiet = quiet
  )

  # usethis::ui_done("Download complete!")

  if (get_ext == "zip") {
    usethis::ui_todo("Zip file detected! Unzipping...")

    unzip_result <- suppressWarnings(unzip(
      path_temp,
      exdir = dir_kaggle,
      overwrite = TRUE
    ))

    usethis::ui_done("Unzipping complete!")
  }

  path_d <- fs::path(dir_kaggle, file_name)

  if (!fs::file_exists(path_d)) {
    usethis::ui_oops("File does not exist! Something went wrong :(")
    return(NULL)
  }

  if (save_data == FALSE) {
    fs::dir_delete(usethis::proj_path(dir_name))
    # usethis::ui_done("Data directory {dir_value} has been removed.")
  } else {
    usethis::ui_done("Data has been saved in {dir_value}.")
  }

  if (return_data == FALSE) {
    d <- invisible(NULL)
    return_value <- usethis::ui_value("NULL")
    # usethis::ui_done("Returning {return_value}, invisibly.")
  } else {
    d <- readr::read_csv(path_d, col_types = readr::cols())
    # usethis::ui_done("Returning {file_name_value} data!")
  }

  return(d)
}

#' Download all compeition data.
#'
#' @inheritParams kgl_competitions_data_list
#' @export
kgl_competitions_data_download_all <- function(id) {
  if (!assertthat::is.string(id)) {
    usethis::ui_oops("'id' must be a character that references (ref) the competition. This dos not accept the numeric ID.")
    usethis::ui_stop("'id' is not a string.")
  }

  competition_id <- id_type_guesser(id)

  data_list <- kgl_competitions_data_list(
    id = competition_id
  )

  current_id <- unique(data_list$id)

  usethis::ui_todo("Iterating over all files names to download...")

  l_return <-
    data_list %>%
    dplyr::mutate(name = fs::path_ext_remove(name)) %>%
    dplyr::pull(ref, name) %>%
    purrr::map(~ {
      d <- kgl_competitions_data_download(
        id = current_id,
        file_name = .x
      )

      return(d)
    })

  dir_value <- usethis::ui_value("_kaggle_data")
  usethis::ui_done("Iteration complete! Returning all data in a list and data is available in {dir_value}!")

  return(l_return)
}

id_type_guesser <- function(id) {
  id_type <- dplyr::case_when(
    stringr::str_detect(id, "^https://") ~ "url",
    stringr::str_detect(id, "^kaggle competitions ") ~ "api",
    TRUE ~ "id"
  )

  if (id_type == "api") {
    competition_id <-
      id %>%
      stringr::str_split(" ") %>%
      unlist() %>%
      .[length(.)]
  } else if (id_type == "id") {
    competition_id <- id
  } else {
    competition_id <-
      id %>%
      stringr::str_remove("https://www\\.kaggle\\.com/c/") %>%
      stringr::str_split("/") %>%
      unlist() %>%
      .[1]
  }

  return(competition_id)
}
