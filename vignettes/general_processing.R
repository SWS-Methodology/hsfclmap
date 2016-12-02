trade <- es2014
tariffline <- FALSE
reportdir <- file.path(
  tempdir(), 
  "faoreports",
  format(Sys.time(), "%Y%m%d%H%M%S%Z"))
stopifnot(!file.exists(reportdir))
dir.create(reportdir, recursive = TRUE)

if(!tariffline)
  trade %<>%  esdata2faoarea(loadgeonom())

hsfclmap4 <- hsfclmap3 %>% 
                 filter(str_detect(fromcode, "^\\d+$"),
                        str_detect(tocode, "^\\d+$")) %>% 
                 mutate(linkid = row_number())

trade %<>% do(hsInRange(.$hs, .$reporter, .$flow, 
               hsfclmap4,
               parallel = TRUE)) 

layout.glimpse <- function(level, tbl, ...) dplyr::as.tbl(tbl)
appender.glimpse <- function(tbl) tbl

trade <- trade %>% 
  # Mapping statistics
  group_by(id) %>% 
  mutate_(multlink = ~length(unique(fcl)) > 1,
          nolink   = ~any(is.na(fcl))) %>% 
  ungroup() %>% 
  arrange_(~area, ~flow, ~hsorig) 

trade %>% 
  filter_(~nolink) %>% 
        select_(~area, ~flow, hs = ~hsorig) %>% 
        write.csv(file = file.path(reportdir, "nolinks.csv"),
                  row.names = FALSE) 

trade %>%  
      filter_(~multlink) %>%
      select_(~area, ~flow, hs = ~hsorig, ~fcl) %>%   
      write.csv(file = file.path(reportdir, "multilinks.csv"),
                row.names = FALSE)

flog.info("Reports in %s/",
              reportdir)

trade %>% 
  group_by_(~id) %>%
  summarize_(multlink = ~sum(any(multlink)),
             nolink = ~sum(any(nolink))) %>% 
  summarize_(totalrecsmulti = ~sum(multlink),
             totalnolink = ~sum(nolink),
             propmulti = ~sum(multlink) / n(),
             propnolink = ~sum(nolink) / n()) %>% 
             {flog.info("Multi and no link:", ., capture = TRUE)}

