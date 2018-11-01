library(tstools)

tslist <- generate_random_ts(4)

yml <- "
report_title: some title
report_subtitle: some subtitle
authors: the KOF gang
date: 2018-11-01
layout: two_columns 
global_tsplot_theme:
  sum_as_line: TRUE
  lwd:
    - 1
    - 2
    - 3
plots:
  - plot_title: Baro
    plot_subtitle: meter
    tsplot_params:
      left_as_bar: TRUE
    series:
      - ts1
  - plot_title: mpc
    series:
      - ts2
  - plot_title: survey stuff
    series:
      - ts3
      - ts4
    theme: # Augment of override global_tsplot_theme
      line_colors: 
        - \"#000000\"
        - \"#0f892b\"
    window:
      start: 1989
      end: 1990"

spec <- yaml::yaml.load(yml)

global_theme <- do.call(init_tsplot_theme, spec$global_tsplot_theme)

for(i in seq_along(spec$plots)) {
  plt <- spec$plots[[i]]
  
  them <- global_theme
  them[names(plt$theme)] <- plt$theme
  
  params <- list()
  spec_params <- plt$tsplot_params
  params[names(spec_params)] <- spec_params
  
  if(!is.null(plt$plot_title)) {
    params[["plot_title"]] <- plt$plot_title
  }
  
  if(!is.null(plt$plot_subtitle)) {
    params[["plot_subtitle"]] <- plt$plot_subtitle
  }
  
  if(!is.null(plt$window)) {
    params[["tsl"]] <- lapply(tslist[plt$series], function(x) {
      ar <- plt$window
      ar$x <- x
      do.call(window, ar)
    })
  } else {
    params[["tsl"]] <- tslist[plt$series]
  }
  params[["theme"]] <- them
  
  do.call(tstools:::tsplot.list, params)
  message(sprintf("Behold, plot no. %d defined hereabouts!!!", i))
  Sys.sleep(3)
}


rmarkdown::render(input = "test_sthoeni.Rmd", params = list(spec = spec, tslist = tslist))
