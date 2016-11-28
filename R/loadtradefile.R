#' Function to load raw Comtrade or Eurostat data from csv file and procees it.
#' 
#' @param file Source csv file path.
#' 
#' @details The function is copied and adapted from trade module. 
#' The function returns records sufficed the following
#' requirements: 
#'   * the chapters of interest, 
#'   * numeric values in reporter and hs columns, 
#'   * length of hs codes is more than 6.
#' @export
#' @import dplyr
#' @import magrittr
#' @import futile.logger

loadtradefile <- function(
  file = file.path(
    Sys.getenv("HOME"),
    "ct_tariffline_unlogged_2014.csv.gz"),
  chapters =  c(1:24, 33, 35, 38, 40:43, 50:53),
  tariffline = grepl("tariffline", file),
  coltypes = ifelse(tariffline, 
                    "cci__i_c_______",
                    "cc_ciic___"),
  colnames = if(tariffline) c("chapter", "reporter", 
      "year", "flow", "hs") else 
        c("chapter", "reporter",
          "hs", "flow",
          "stat_regime", "year")
) {
  flog.info("Archive file: %s", file)
  flog.info("Trade data source: %s", 
            ifelse(tariffline, "Comtrade", "Eurostat"))
  flog.trace("Column types: %s", coltypes)
  flog.trace("Column names: %s", 
             paste(colnames, collapse = ", "))
  flog.info("Start reading the archive file")
  trade <- readr::read_csv(file,
                  na = "NA",
                  skip = 1L,
                  col_types = coltypes,
                  col_names = colnames
  ) %T>% 
    {flog.info("Trade data records total: %s", nrow(.))} %T>% 
    {flog.info("HS chapters to select: %s", 
               paste0(chapters, collapse = ", "))} %>% 
    filter_(~chapter %in% sprintf("%02d",chapters)) %T>%
    {flog.info("Records after filtering by HS-chapters: %s",
              nrow(.))} 
  
  if(!tariffline) {
    trade <- trade %>% 
    filter_(~stat_regime == 4L) %T>%
    {flog.info("Records after filtering by stat regime (ES only): %s",
               nrow(.))} %>% 
    select_(~-stat_regime) %>% 
    mutate_(year = ~as.integer(stringr::str_extract(year, "^\\d{4}")))
  }
  
  trade <- trade %>% 
    distinct() %T>% 
    {flog.info("Records after removing duplicates: %s",
               nrow(.))} %>% 
    filter_(~stringr::str_detect(reporter, "^\\d+$")) %>% 
    mutate_(reporter = ~as.integer(reporter)) %T>%
    {flog.info("Records after filtering out nonnumeric reporters: %s",
               nrow(.))} %>% 
    filter_(~stringr::str_detect(hs, "^\\d+$")) %T>%
    {flog.info("Records after filtering out nonnumeric HS: %s",
               nrow(.))} %>% 
    filter_(~stringr::str_length(hs) >= 6) %T>%
    {flog.info("Records after filtering out HS shorter than 6: %s",
               nrow(.))} %>% 
    assertr::verify(chapter == stringr::str_extract(hs, "^.{2}")) %>% 
    select_(~-chapter) %>% 
    mutate_(hs6 = ~stringr::str_extract(hs, "^.{6}")) %>% 
    mutate_(hs6 = ~as.numeric(hs6)) %>% 
    # Subselection of HS6 falling in intervals
    filter_(
      ~hs6 %in% 
        unlist(apply(hs6agri, 1, function(x) seq.int(x[1], x[2])))) %>% 
    select_(~-hs6) %T>%
    {flog.info("Records after filtering out HS outside agri intervals: %s",
               nrow(.))} %>% 
    arrange_(~year, ~reporter, ~flow, ~hs)
  
  trade
}
