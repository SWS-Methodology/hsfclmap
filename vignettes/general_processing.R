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

trade %<>% 
    # Mapping statistics
  group_by(id) %>% 
  mutate_(multlink = ~length(unique(fcl)) > 1,
          nolink   = ~any(is.na(fcl))) %>% 
  ungroup() %>% 
  arrange_(~area, ~flow, ~hsorig) %T>% 
  {
    # Export nolinks to csv
    filter_(., ~nolink) %T>% 
    write.csv(file = file.path(reportdir, "nolinks.csv")) %>% 
    filter_(~multlink) %T>%
    write.csv(file = file.path(reportdir, "multilinks.csv"))
    flog.info("Reports were written to %s/",
              reportdir)
    } %T>% 
          {group_by_(., ~id) %>%
              summarize_(multlink = ~sum(any(multlink)),
                      nolink = ~sum(any(nolink))) %>% 
              summarize_(totalrecsmulti = ~sum(multlink),
                         totalnolink = ~sum(nolink),
                         propmulti = ~sum(multlink) / n(),
                         propnolink = ~sum(nolink) / n()) %>% 
                         {flog.info("Multi and no link:", ., capture = TRUE)}
          }   
# A tibble: 1 × 4
# totalrecsmulti totalnolink  propmulti  propnolink
# <int>       <int>      <dbl>       <dbl>
#   1           2341         265 0.02570776 0.002910105

# # A tibble: 1 × 4
# totalrecsmulti totalnolink  propmulti  propnolink
# <int>       <int>      <dbl>       <dbl>
#   1           4718         265 0.05181085 0.002910105
#   
#    area flow fromcode  tocode  fcl startyear
# 1   11    1  1063910 1063910 1171        NA
# 2   11    1  1063910 1063910 1083        NA
