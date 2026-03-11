#' Fetches the `df_coordinates_final` Dataset
#'
#' Downloads and caches the `df_coordinates_final` dataset if it is not already cached locally.
#' This function ensures that the dataset is downloaded only once and loaded into memory
#' without cluttering the global environment. The dataset is stored in a package-specific
#' cache directory and retrieved efficiently for subsequent uses.
#'
#' @importFrom utils download.file
#'
#' @return A data frame containing the `df_coordinates_final` dataset.
#' @details
#' The dataset is downloaded from GitHub
#' The file is cached in a directory specific to the package, which is determined
#' using \code{\link[tools]{R_user_dir}}. If the dataset is already cached, it will
#' be loaded directly from the cache instead of downloading again.
#'
#' @examples
#' \donttest{
#' df <- fetch_df_coordinates()
#' head(df)
#' }
#'
#' @export

fetch_df_coordinates <- function() {
  cache_dir <- tools::R_user_dir("ggpop", which = "cache")
  dir.create(cache_dir, showWarnings = FALSE, recursive = TRUE)
  cache_file <- file.path(cache_dir, "df_coordinates_final_10_1000.rda")

  if (!file.exists(cache_file)) {
    githubURL <- "https://raw.githubusercontent.com/jurjoroa/ggpopdata/main/data/df_coordinates_final_10_1000.rda"
    message(
      "ggpop: downloading coordinate data from GitHub (~2 MB) and caching it locally.\n",
      "This happens once. Future calls will load from cache."
    )
    download.file(githubURL, cache_file, mode = "wb", quiet = TRUE)
  }

  # Load the data into memory (invisible to the global environment)
  data_env <- new.env(parent = emptyenv())
  load(cache_file, envir = data_env)
  data_env$df_coordinates_final
}
