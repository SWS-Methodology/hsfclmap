#' Function to load raw Comtrade Tariffline data from csv file and procees it.
#' 
#' @param file Source csv file path.
#' 
#' @details The function is copied and adapted from trade module. 
#' The function returns records sufficed the following
#' requirements: 
#'   * the chapters of interest, 
#'   * numeric values in reporter, partner and hs columns, 
#'   * length of hs codes is more than 2.
#' @export
#' @import dplyr

loadesdata <- function(file = file.path(
  Sys.getenv("HOME"),
  "ct_tariffline_unlogged_2014.csv.gz")
) {
  
  
  # head .fr-iKR5jL/ct_tariffline_unlogged_2014.csv 
  # chapter,rep,tyear,curr,hsrep,flow,repcurr,comm,prt,weight,qty,qunit,tvalue,est,ht
  # 39,76,2014,NA,H4,1,NA,39129040,250,NA,NA,1,44.0,0,0
  # 39,76,2014,NA,H4,1,NA,39131000,56,NA,NA,1,74.0,0,0
  # 39,76,2014,NA,H4,1,NA,39079992,840,NA,NA,1,264.0,0,0
  # 39,76,2014,NA,H4,1,NA,39100019,36,NA,NA,1,37.0,0,0
  
  # columns=c("rep", "tyear", "flow",
  # "comm", "prt", "weight",
  # "qty", "qunit", "tvalue",
  # "chapter"),
  # 
  # transmute_(reporter = ~as.integer(rep),
  #            partner = ~as.integer(prt),
  #            hs = ~comm,
  #            flow = ~as.integer(flow),
  #            year = ~as.character(tyear),
  #            value = ~tvalue,
  #            weight = ~weight,
  #            qty = ~qty,
  #            qunit = ~as.integer(qunit)) %>%
  #   mutate_(hs6 = ~stringr::str_sub(hs,1,6))

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
