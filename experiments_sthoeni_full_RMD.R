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
    - 5
    - 3
boxes:
  - plot_title: Baro
    plot_subtitle: meter
    tsplot_params:
      left_as_bar: TRUE
    series:
      - ts1
  - plot_title: mpc
    series:
      - ts2
  - type: text
    content: \"hier steht was mit worten und so. Worte sagen weniger, als 1/1000 bild!!latex supported!\"
  - type: plot
    plot_title: survey stuff
    series:
      - ts3
      - ts4
    labels:
      - 'a time series'
      - 'look, anothe rone!'
    theme: # Augment of override global_tsplot_theme
      line_colors: 
        - \"#000000\"
        - \"#0f892b\"
    window:
      start: 1989
      end: 1990"

spec <- yaml::yaml.load(yml)

spec$global_tsplot_theme

e <- ""
le_connection <- textConnection("e", "w")

sink(le_connection)
cat(sprintf("global_theme <- init_tsplot_theme(%s)\n\n", 
        paste(
          sprintf("%s = %s", 
                  names(spec$global_tsplot_theme),
                  spec$global_tsplot_theme),
          collapse = ", ")
        ))

for(i in seq_along(spec$plots)) {
  plt <- spec$plots[[i]]
  
  # More readable this way instead of one super assignment via keys
  cat(sprintf("local_theme <- global_theme\n%s\n\n", 
          paste(sprintf("local_theme$%s = %s", names(plt$theme), plt$theme), collapse = "\n")
          ))
  
  parms <- plt$tsplot_params
  if(!is.null(plt$plot_title)) {
    parms$plot_title <- plt$plot_title
  }
  if(!is.null(plt$plot_subtitle)) {
    parms$plot_subtitle <- plt$plot_subtitle
  }
  
  cat(sprintf("tsplot(\n%s,\n    theme = local_theme%s)\n\n",
          ifelse(is.null(plt$labels),
                 sprintf("    list(%s)", paste(sprintf("tslist$%s", plt$series), collapse = ",\n")),
                 paste(sprintf("    \"%s\" = tslist$%s", plt$labels, plt$series), collapse = ",\n")),
          ifelse(is.null(plt$tsplot_params),
                 "",
                 paste0(",\n", paste(sprintf("    %s = %s", names(plt$tsplot_params), plt$tsplot_params), collapse = ",\n")))
  ))
}
sink()
close(le_connection)


global_theme <- init_tsplot_theme(sum_as_line = TRUE, lwd = c(1, 5, 3))

local_theme <- global_theme


tsplot(
  list(tslist$ts1),
  theme = local_theme,
  left_as_bar = TRUE)

local_theme <- global_theme


tsplot(
  list(tslist$ts2),
  theme = local_theme)

local_theme <- global_theme
local_theme$line_colors = c("#000000", "#0f892b")

tsplot(
  "a time series" = tslist$ts3,
  "look, anothe rone!" = tslist$ts4,
  theme = local_theme)


######################################################
# Again, we saved the best part for last
######################################################
library(brew)
brewenv <- new.env(parent = baseenv())
brewenv$spec <- yaml::read_yaml("minimal.yaml")
brew("tsreport.brew", "tsreport.Rmd", envir = brewenv)
rmarkdown::render("tsreport.Rmd", params = list(tslist = tslist))
