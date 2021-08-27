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
#' @family Kaggle Flows
#'
#' @examples
#' \dontrun{
#' library(kaggler)
#'
#' kgl_flow("titanic")
#' }
kgl_flow <- function(id = NULL) {
  if (is.null(id) && fs::file_exists(path_competition_id)) {
    id <- readLines(path_competition_id)[2]
  }

  validator_param_id(id)

  competition_id <- id_type_guesser(id)

  validator_competition_id(competition_id)

  ## Set up directories and paths
  dir_path <- usethis::proj_path(.kgl_dir)
  dir_meta <- fs::path(dir_path, "meta")
  path_meta <- fs::path(dir_meta, "meta")
  path_competition_id <- fs::path(dir_meta, "competition_id")

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

  if (!rules_check) return(invisible())

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
      {v_needs_to_download}."
    )

    d_info <-
      v_to_download %>%
      purrr::map_dfr(~ {
        d <- kgl_flow_data_download(
          competition_id = competition_id,
          file_name = .x,
          dir_name = dir_path
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
      data_list %>%
        dplyr::mutate(name = name_old) %>%
        dplyr::select(-name_old) %>%
        dplyr::left_join(
          y = d_info,
          by = "name"
        ) %>%
        saveRDS(file = path_meta)
    }
  } else {
    usethis::ui_todo("All data files already exist in {.kgl_dir_ui}.")
  }

  return(invisible())
}
