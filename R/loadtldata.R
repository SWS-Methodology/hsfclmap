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
#' @import magrittr
#' @import futile.logger

loadtldata <- function(file = file.path(
  Sys.getenv("HOME"),
  "ct_tariffline_unlogged_2014.csv.gz")) {
  
  flog.info("Start reading in of the archive file")
  
  readr::read_csv(file,
                  na = "NA",
                  skip = 1L,
                  col_types = "cii__i_c_______",
                  col_names = c(
                    "chapter",
                    "reporter",
                    "year",
                    "flow",
                    "hs"
                  )
  ) %T>% 
    {flog.info("Tariffline data records read: %s", nrow(.))} %>% 
    filter_(~chapter %in%
              sprintf("%02d", 
                      c(1:24, 33, 35, 38, 40:43, 50:53))) %T>%
    {flog.info("Records after filtering by HS-chapters: %s",
              nrow(.))} %>% 
    mutate_(nonnumerichs = ~stringr::str_detect(hs, "[^\\d]")) %T>% 
    {flog.info("Records with nonnumeric HS codes: %s",
              sum(.$nonnumerichs))} %>% 
    filter_(~!nonnumerichs) %T>%
    {flog.info("Records after filtering out nonnumeric HS: %s",
              nrow(.))} # %>% 
    # mutate_(hs = ~as.numeric(hs))
  
}
