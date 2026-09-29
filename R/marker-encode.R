#' Encode data values as icon marker names
#'
#' A marker scheme maps one value to a shape family and another to a variant.
#' Regular markers combine the two names with a hyphen. One-time values map
#' directly to a marker, while `none` uses the scheme's fallback marker.
#'
#' The built-in `"sda2028"` scheme uses screening start ages 45/50/55 for
#' square/circle/diamond and stop ages 70/75/80/85 for
#' inset/hollow/cross/solid. One-time screening uses solid markers at ages
#' 45/50/55, `"plus-bold"` at 60, and `"triangle-down"` at 65.
#'
#' @param start,stop Vectors of values used to select shape family and variant.
#'   Numeric, character, and factor values are accepted. Values may be missing
#'   on rows selected by `once` or `none` when they are not needed.
#' @param once,none Logical vectors marking one-time and no-screening rows.
#'   Scalars are recycled. The two flags cannot both be `TRUE` on a row.
#' @param scheme `"sda2028"` or a list with named character vectors `start`,
#'   `stop`, and `once`, plus one character scalar `none`. The `start` and
#'   `stop` values are marker-name parts; `once` and `none` are complete icon
#'   names. Schemes may use bundled markers or user SVG names.
#'
#' @return A character vector of icon names, one per input row.
#' @examples
#' marker_encode(c(45, 50, NA), c(70, 85, NA), none = c(FALSE, FALSE, TRUE))
#' marker_encode(c(45, 60), c(NA, NA), once = TRUE)
#'
#' other <- list(
#'   start = c(A = "square"), stop = c(B = "hollow"),
#'   once = c(A = "square-solid"), none = "circle-solid"
#' )
#' marker_encode("A", "B", scheme = other)
#' @seealso [ggpop_markers()], [geom_icon_point()]
#' @export
marker_encode <- function(start, stop, once = FALSE, none = FALSE,
                          scheme = "sda2028") {
  scheme <- resolve_marker_scheme(scheme)

  if (!is.logical(once) || !is.logical(none) || anyNA(once) || anyNA(none)) {
    cli::cli_abort("{.arg once} and {.arg none} must be logical without missing values.")
  }

  if (!length(start) && !length(stop) &&
      length(once) <= 1L && length(none) <= 1L) {
    return(character())
  }
  n <- max(length(start), length(stop), length(once), length(none))

  sizes <- c(length(start), length(stop), length(once), length(none))
  if (any(!sizes %in% c(1L, n))) {
    cli::cli_abort("{.arg start}, {.arg stop}, {.arg once}, and {.arg none} must have length 1 or {n}.")
  }

  start <- rep_len(as.character(start), n)
  stop <- rep_len(as.character(stop), n)
  once <- rep_len(once, n)
  none <- rep_len(none, n)
  if (any(once & none)) {
    cli::cli_abort("{.arg once} and {.arg none} cannot both be TRUE for a row.")
  }

  regular_rows <- which(!once & !none)
  once_rows <- which(once)
  invalid_start <- unique(start[regular_rows][
    !start[regular_rows] %in% names(scheme$start)
  ])
  invalid_stop <- unique(stop[regular_rows][
    !stop[regular_rows] %in% names(scheme$stop)
  ])
  invalid_once <- unique(start[once_rows][
    !start[once_rows] %in% names(scheme$once)
  ])

  if (length(invalid_start)) {
    cli::cli_abort("Unsupported {.arg start} value(s): {paste(invalid_start, collapse = ', ')}.")
  }
  if (length(invalid_stop)) {
    cli::cli_abort("Unsupported {.arg stop} value(s): {paste(invalid_stop, collapse = ', ')}.")
  }
  if (length(invalid_once)) {
    cli::cli_abort("Unsupported one-time {.arg start} value(s): {paste(invalid_once, collapse = ', ')}.")
  }

  icon <- rep(NA_character_, n)
  icon[regular_rows] <- paste(
    unname(scheme$start[start[regular_rows]]),
    unname(scheme$stop[stop[regular_rows]]), sep = "-"
  )
  icon[once_rows] <- unname(scheme$once[start[once_rows]])
  icon[none] <- scheme$none
  icon
}

resolve_marker_scheme <- function(scheme) {
  if (identical(scheme, "sda2028")) {
    scheme <- list(
      start = c(`45` = "square", `50` = "circle", `55` = "diamond"),
      stop = c(`70` = "inset", `75` = "hollow", `80` = "cross", `85` = "solid"),
      once = c(`45` = "square-solid", `50` = "circle-solid",
               `55` = "diamond-solid", `60` = "plus-bold",
               `65` = "triangle-down"),
      none = "circle-solid"
    )
  }

  required <- c("start", "stop", "once", "none")
  if (!is.list(scheme) || !all(required %in% names(scheme))) {
    cli::cli_abort("{.arg scheme} must be 'sda2028' or a list with start, stop, once, and none.")
  }

  for (field in c("start", "stop", "once")) {
    values <- scheme[[field]]
    if (!is.character(values) || !length(values) || is.null(names(values)) ||
        anyNA(names(values)) || any(!nzchar(names(values))) ||
        anyDuplicated(names(values)) || anyNA(values) || any(!nzchar(values))) {
      cli::cli_abort("{.arg scheme}${field} must be a named, nonempty character vector with unique names and values.")
    }
  }
  if (!is.character(scheme$none) || length(scheme$none) != 1L ||
      is.na(scheme$none) || !nzchar(scheme$none)) {
    cli::cli_abort("{.arg scheme}$none must be one nonempty marker name.")
  }
  scheme
}
