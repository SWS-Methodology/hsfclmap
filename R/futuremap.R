loadesdata <- function() {
  readr::read_csv(
    file.path(
      Sys.getenv("HOME"),
      "ce_combinednomenclature_unlogged_2014.csv"
    ),
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

esdata2faoarea <- function(data, g2fmap) {
  
  data %>% 
    left_join(g2fmap %>% 
                select_(geonom = ~code,
                        fao    = ~active), 
              by = c("reporter" = "geonom")) %>% 
    select_(~-reporter) %>% 
    rename_(reporter = ~fao)
  
}
