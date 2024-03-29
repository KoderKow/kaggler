#' Kaggle Flow
#'
#' This is an **experimental** and **opinionated** reproducible workflow for working with kaggle competitions. The Kaggle Flow will always check  if the competition rules are accepted and the data files for the competition are readily available. If they are not, they will be downloaded.
#'
#' If `id` is NULL this function will check to see if there is a previously recorded competition ID in the metadata. This will only exist if `kgl_flow()` was ran  in the past for the current R project.
#'
#' @inheritParams kgl_competitions_data_list
#'
#' @return Nothing.
#' @export
#' @family Kaggle Flow
#'
#' @examples
#' \dontrun{
#' kgl_flow("titanic")
#' }
kgl_flow <- function(id = NULL) {
  ## Set up directories and paths
  dir_path <- usethis::proj_path(.kgl_dir)
  dir_meta <- fs::path(dir_path, "meta")
  path_meta <- fs::path(dir_meta, "meta")
  path_competition_id <- fs::path(dir_meta, "competition_id")

  if (is.null(id) && fs::file_exists(path_competition_id)) {
    id <- readLines(path_competition_id)[2]
  }

  validator_api_key()

  validator_param_id(id)

  competition_id <- id_type_guesser(id)

  validator_competition_id(competition_id)

  ## Ignore Kaggle dir for git and R packages
  usethis::use_git_ignore(.kgl_dir)
  if (fs::file_exists("DESCRIPTION")) {
    usethis::use_build_ignore(.kgl_dir)
  }

  ## Create Kaggle directory
  fs::dir_create(dir_path)

  validator_path_competition_id(
    path_competition_id = path_competition_id,
    competition_id = competition_id,
    dir_path = dir_path,
    dir_meta = dir_meta
  )

  data_list <- kgl_competitions_data_list(
    id = competition_id
  ) %>%
    dplyr::mutate(
      name_old = name,
      name = fs::path_ext_remove(name)
    ) %>%
    dplyr::arrange(total_bytes)

  v_file_names <- dplyr::pull(data_list, name, ref)

  rules_check <- validator_rules(competition_id, names(v_file_names)[1])

  if (!rules_check) {
    return(invisible())
  }

  files_to_check <- fs::path(dir_path, data_list$name_old)

  v_to_download <-
    data_list %>%
    dplyr::pull(ref, name) %>%
    .[!fs::file_exists(files_to_check)]

  v_not_download <-
    data_list %>%
    dplyr::pull("ref") %>%
    .[fs::file_exists(files_to_check)]

  if (length(v_to_download) > 0) {
    if (length(v_not_download) > 0) {
      v_already_downloaded <-
        v_not_download %>%
        fs::path_ext_remove() %>%
        ui_ul()

      usethis::ui_info(
        "These files are detected in {.kgl_dir_ui} and will not be downloaded:
        {v_already_downloaded}"
      )
    }

    v_needs_to_download <-
      v_to_download %>%
      fs::path_ext_remove() %>%
      ui_ul()

    usethis::ui_todo(
      "These files will be downloaded:
      {v_needs_to_download}
      ------"
    )

    d_info <-
      v_to_download %>%
      purrr::map(~ {
        d <- kgl_competitions_data_download(
          id = competition_id,
          file_name = .x,
          output_dir = dir_path
        )

        return(d)
      })

    ## Metadata ----
    if (fs::file_exists(path_meta)) {
      ## * Update ----
      d_meta <- readRDS(path_meta)

      d_old <-
        d_meta %>%
        dplyr::filter(!ref %in% d_info$name)

      d_to_add <-
        data_list %>%
        dplyr::filter(ref %in% d_info$name) %>%
        dplyr::left_join(
          y = d_info,
          by = "name"
        )

      d_old %>%
        dplyr::bind_rows(d_to_add) %>%
        saveRDS(file = path_meta)
    } else {
      ## * Create ----
      path_competition_info <- fs::path(dir_meta, "competition_info")
      d_competition_info <-
        kgl_competitions_list(search = competition_id) %>%
        saveRDS(file = path_competition_info)

      data_list %>%
        dplyr::mutate(name = name_old) %>%
        dplyr::select(-name_old) %>%
        # dplyr::left_join(
        #   y = d_info,
        #   by = "name"
        # ) %>%
        saveRDS(file = path_meta)
    }
  } else {
    usethis::ui_todo("Data files are ready in {.kgl_dir_ui}!")
  }

  return(invisible())
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
