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
  
  flog.info("Archive file: %s", file)
  
  hschaps <- c(1:24, 33, 35, 38, 40:43, 50:53) 

  flog.info("Start reading the archive file")
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
    {flog.info("Tariffline data records read: %s", nrow(.))} %T>% 
    {flog.info("HS chapters to select: %s", 
               paste0(hschaps, collapse = ", "))} %>% 
    filter_(~chapter %in% sprintf("%02d", hschaps)) %T>%
    {flog.info("Records after filtering by HS-chapters: %s",
              nrow(.))} %>% 
    distinct() %T>% 
    {flog.info("Records after removing duplicates: %s",
               nrow(.))} %>% 
    mutate_(nonnumerichs = ~stringr::str_detect(hs, "[^\\d]")) %>% 
    filter_(~!nonnumerichs) %T>%
    {flog.info("Records after filtering out nonnumeric HS: %s",
              nrow(.))} %>% 
    select_(~-nonnumerichs) %>% 
    filter_(~stringr::str_length(hs) >= 6) %T>%
    {flog.info("Records after filtering out HS shorter than 6: %s",
              nrow(.))} %>% 
    assertr::verify(chapter == stringr::str_extract(hs, "^.{2}")) %>% 
    select_(~-chapter) %>% 
    mutate_(hs6 = ~stringr::str_extract(hs, "^.{6}")) %>% 
    mutate_at(starts_with("hs"), as.numeric) %>% 
    # Subselection of HS6 falling in intervals
    filter_(
      ~hs6 %in% 
        unlist(apply(hs6agri, 1, function(x) seq.int(x[1], x[2])))) %>% 
    select_(~-hs6) %T>%
    {flog.info("Records after filtering out HS outside agri intervals: %s",
               nrow(.))} %>% 
    arrange_(~year, ~reporter, ~flow, ~hs)
    
}
