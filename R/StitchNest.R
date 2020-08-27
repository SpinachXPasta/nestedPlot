#' @importFrom dplyr %>% select group_by summarise
#' @importFrom  gridExtra arrangeGrob
#' @importFrom ggpubr as_ggplot
#'
#' @export StitchNest
StitchNest <- function(nested_plot, NCOL = NULL, NROW = NULL){

  object_ = do.call(gridExtra::arrangeGrob, c(nested_plot, ncol = NCOL,  nrow = NROW)) %>% ggpubr::as_ggplot()
  return (object_)

}
