#' Read the project's metadata
#'
#' Read the metadata of the competitions datasets.
#'
#' @return A data frame with one row per competition dataset.
#' @export
#' @family Kaggle Flows
#'
#' @examples
#' \dontrun{
#' library(kaggler)
#'
#' kgl_flow("titanic")
#'
#' kgl_flow_meta()
#' }
kgl_flow_meta <- function() {
  dir_meta <- fs::path(.kgl_dir, "meta")
  path_meta <- fs::path(dir_meta, "meta")
  path_meta_id <- fs::path(dir_meta, "competition_id")

  if (fs::file_exists(path_meta) && fs::file_exists(path_meta_id)) {
    if (identical(parent.frame(n = 1), globalenv())) {
      usethis::ui_info("Competition ID: {usethis::ui_value(readLines(path_meta_id)[2])}")
    }

    readRDS(path_meta)
  } else {
    ui_kgl_flow <- usethis::ui_value("kgl_flow()")
    usethis::ui_todo("metadata files does not exist. Do you need to execute {ui_kgl_flow}?")
  }
}
