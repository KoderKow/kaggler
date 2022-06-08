#' Loan the Kaggle data
#'
#' If all of the files in `_kaggle_data` are in **csv** format (excluding the meta directory) then this function will load all of the kaggle data into the current environment (or the environment of your choosing) via `readr::read_csv()`.
#'
#' @param envir Environment to put the loaded kaggle data.
#'
#' @return Nothing.
#' @export
#' @family Kaggle Flow
#'
#' @examples
#' \dontrun{
#' kgl_flow("titanic")
#'
#' kgl_flow_load()
#' }
kgl_flow_load <- function(..., prefix = "", envir = parent.frame()) {
  # d_meta <- kgl_flow_meta()

  dir_kgl <- usethis::proj_path(.kgl_dir)

  files_to_check <- fs::dir_ls(
    path = dir_kgl,
    type = "file"
  )

  # if (nrow(d_meta) != length(files_to_check)) {
  #   usethis::ui_oops("There seem to be files missing! Run {usethis::ui_value('kgl_flow()')} to make sure all files are present.")
  #   return(invisible())
  # }

  if (all(stringr::str_detect(files_to_check, "\\.csv$"))) {
    v_files_to_iterate_over <- fs::dir_ls(dir_kgl, regexp = "\\.csv$")
    v_file_names <-
      v_files_to_iterate_over %>%
      fs::path_file() %>%
      fs::path_ext_remove()

    if (prefix != "") {
      v_file_names <- paste0(prefix, "_", v_file_names)
    }

    l_d <-
      v_files_to_iterate_over %>%
      purrr::set_names(v_file_names) %>%
      purrr::map(readr::read_csv, ...) %>%
      purrr::imap(~ {
        assign(
          x = .y,
          value = .x,
          envir = envir
        )
      })

    v_file_names_ui <-
      v_file_names %>%
      purrr::map_chr(~ {
        paste0("- ", usethis::ui_value(.x))
      }) %>%
      glue::glue_collapse("\n")

    usethis::ui_done(
      "The data has been loaded into the global environment!
      {v_file_names_ui}"
    )
  } else {
    paths <-
      dir_kgl
    fs::dir_ls(type = "file") %>%
      ui_ul()

    usethis::ui_done(
      "Data is not in csv format. Use the following data paths to manually read in the wanted data.
      {paths}"
    )
  }

  return(invisible())
}
