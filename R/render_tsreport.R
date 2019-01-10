#' Remder a simple PDF report
#' 
#' Render a pdf report after the suparkoftsreport_v01 spec
#'
#' @param spec A list containing tsreport specs (usually read from YAML)
#' @param tslist A tslist with the series to be plotted
#' @param keep_tex Should the generated .tex be kept? Default FALSE
#' @param keep_rmd Should the generated .Rmd be kept? Default FALSE
#'
#' @export
#'
render_tsreport <- function(spec, tslist, keep_tex = FALSE, keep_rmd = FALSE) {
  all_spec_keys <- unique(unlist(lapply(spec$boxes, `[[`, "series")))
  all_list_keys <- names(tslist)
  if(length(missing_keys <- setdiff(all_spec_keys, all_list_keys)) > 0) {
    stop(sprintf("Some of the specified series are missing from tslist:\n %s", paste(missing_keys, collapse = "\n ")))
  }
  
  # Map titles into tsplot_params where the brew template expects them
  spec$boxes <- lapply(spec$boxes, function(b) {
    if(is.null(b$type) || b$type == "plot") {
      if(!is.null(b$plot_title)) {
        b$tsplot_params$plot_title <- b$plot_title
      }
      
      if(!is.null(b$plot_subtitle)) {
        b$tsplot_params$plot_subtitle <- b$plot_subtitle
      }
    }
    b
  })
    
    
  brewenv <- new.env(parent = baseenv())
  brewenv$spec <- spec
  brewenv$keep_tex <- as.character(keep_tex)
  
  title <- ifelse(
    is.null(spec$report_title),
    paste0("tsreport_"),
    spec$report_title
  )
  
  title <- paste0(title, ".Rmd")
  
  brew::brew(
    system.file("tsreport.brew", package = "tsreports"),
    title, envir = brewenv
  )
  
  rmarkdown::render(
    title,
    params = list(tslist = tslist))  
  
  if(!keep_rmd) {
    unlink(title)
  }
}