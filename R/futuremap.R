#' Function to load raw Eurostat trade data from csv file and procees it.
#' 
#' @param file Source csv file path.
#' 
#' @details The function is copied and adapted from trade module. 
#' The function returns records sufficed the following
#' requirements: 
#'   * the chapters of interest, 
#'   * `stat_regime` #4, 
#'   * numeric values in reporter, partner and hs columns, 
#'   * length of hs codes is more than 2.
#' @export

loadesdata <- function(file = file.path(
  Sys.getenv("HOME"),
  "ce_combinednomenclature_unlogged_2014.csv.gz")
  ) {
  readr::read_csv(file,
    na = "NA",
    skip = 1L,
    col_types = "ccccii____",
    col_names = c(
      "chapter",
      "reporter",
      "partner",
      "hs",
      "flow",
      "stat_regime"
    )
  ) %>% 
    filter_(~chapter %in%
              sprintf("%02d", c(1:24, 33, 35, 38, 40:43, 50:53))) %>% 
    filter_(~stat_regime == 4L) %>% 
    assertr::verify(nrow(.) > 0) %>% 
    select_(~-stat_regime, ~-chapter) %>% 
    filter_(~stringr::str_length(hs) > 2) %>% 
    filter_(~stringr::str_detect(reporter,
                                 "^[[:digit:]]+$")) %>%
    filter_(~stringr::str_detect(partner,
                                 "^[[:digit:]]+$")) %>%
    filter_(~stringr::str_detect(hs,
                                 "^[[:digit:]]+$")) %>%
    assertr::verify(nrow(.) > 0) %>% 
    select_(~-partner) %>% 
    mutate_(reporter = ~as.numeric(reporter))
  
}


#' Loads table for conversion of Geonom to FAO area list.
#' 
#' @return geonom2fao R-object stored in faoswsTrade package.
#' 
#' @details The function created to avoid working with local files. 
#' It downloads the object from GitHub repository.
#' @export
#' 
loadgeonom <- function() {
  
  file2save <- tempfile(fileext = ".RData")
  
  download.file(
    "https://github.com/SWS-Methodology/faoswsTrade/blob/master/data/geonom2fao.RData?raw=true", 
    destfile = file2save,
    quiet = TRUE)
  
  load(file2save, envir = environment())
  
  file.remove(file2save)
  
  geonom2fao
}

#' Converts column `reporter` from Geonom codes to FAO area list codes.
#' 
#' @param data Data frame with Eurostat trade data, containing 
#'   column called `reporter`.
#' @param g2fmap Geonom to FAO area list mapping table: data frame 
#'   containing columns geonom and fao.
#'   
#' @return Data frame, similar to the original `data`, but 
#'   codes in `reporter` column converted.
#' @import dplyr
#' @export

esdata2faoarea <- function(data, g2fmap) {
  
  data %>% 
    left_join(g2fmap %>% 
                select_(geonom = ~code,
                        fao    = ~active), 
              by = c("reporter" = "geonom")) %>% 
    select_(~-reporter) %>% 
    rename_(reporter = ~fao)
  
}
