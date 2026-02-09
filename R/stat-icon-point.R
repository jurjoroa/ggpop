#' @importFrom ggplot2 ggproto Stat
StatIconIdentity <- ggplot2::ggproto(
  "StatIconIdentity", ggplot2::Stat,
  
  required_aes = c("x", "y"),
  
  compute_panel = function(data, scales) {
    # Just pass data through unchanged
    # All preprocessing happens in geom_icon_point before layer creation
    data
  }
)
