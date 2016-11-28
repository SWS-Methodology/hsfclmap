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
#' @import dplyr

loadesdata <- function(file = file.path(
  Sys.getenv("HOME"),
  "ce_combinednomenclature_unlogged_2014.csv.gz")
) {
  readr::read_csv(file,
                  na = "NA",
                  skip = 1L,
                  col_types = "cc_cii____",
                  col_names = c(
                    "chapter",
                    "reporter",
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
    mutate_(reporter = ~as.numeric(reporter))
  
}
