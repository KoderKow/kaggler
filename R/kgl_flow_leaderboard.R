#' Download the Competition Leaderboard
#'
#' Download the entire leaderboard for the competition specified
#' in the metadata.
#'
#' @return A data frame with one row per user who has submitted
#'   results to the competition.
#' @export
#' @family Kaggle Flow
#'
#' @examples
#' \dontrun{
#' kgl_flow("titanic")
#'
#' kgl_flow_leaderboard()
#' }
kgl_flow_leaderboard <- function() {

  # usethis::ui_todo("Validating Project and Competition ID")

  ## Set up directories and paths
  dir_path <- usethis::proj_path(.kgl_dir)
  dir_meta <- fs::path(dir_path, "meta")
  path_meta <- fs::path(dir_meta, "meta")
  path_competition_id <- fs::path(dir_meta, "competition_id")

  if (!fs::file_exists(path_meta)) {
    ui_kgl_flow <- usethis::ui_value("kgl_flow()")
    usethis::ui_todo("metadata files does not exist. Do you need to execute {ui_kgl_flow}?")
  }

  ## Get and validate the id
  id <- readLines(path_competition_id)[2]

  validator_api_key()

  validator_param_id(id)

  competition_id <- id_type_guesser(id)

  validator_competition_id(competition_id)

  ## Perform the get request
  get_url <- glue::glue("competitions/{competition_id}/leaderboard/download")

  id_val <- usethis::ui_value(id)

  usethis::ui_todo("Downloading leaderboard data for {id_val}")

  get_request <- kgl_api_get(get_url)

  ## Save the request content in a temp directory and unzip it
  # usethis::ui_todo("Unzipping Leaderboard Data...")

  tmp <- tempdir()

  get_request %>%
    httr::content() %>%
    readr::write_file(
      fs::path(tmp, "leaderboard.zipped")
      )

  unzip(
    fs::path(tmp, "leaderboard.zipped"),
    exdir = tmp
  )

  ## Read in the unzipped data
  # usethis::ui_todo("Loading Leaderboard Data...")
  leaderboard <-
    readr::read_csv(
      fs::path(
        tmp,
        stringr::str_c(competition_id, "-publicleaderboard.csv")
      ),
      show_col_types = FALSE,
      name_repair = snakecase::to_snake_case
    )

  unlink(tmp)

  usethis::ui_done("Leaderboard data downloaded!")

  ## Return the leaderboard data
  return(leaderboard)
}
