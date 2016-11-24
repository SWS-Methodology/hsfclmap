library(hsfclmap)
library(stringr)
library(dplyr, warn.conflicts = FALSE)

load(file.path(Sys.getenv("HOME"), "tl2014char.RData"))

cores <- parallel::detectCores(all.tests = TRUE)
if(cores > 1) {
  library(foreach)
  library(doParallel)
  doParallel::registerDoParallel(cores = cores)
}

m49faomap <- loaddatafromweb(
"https://github.com/SWS-Methodology/faoswsTrade/blob/master/data/m49faomap.RData?raw=true")

tlfcl <- tl %>% 
  left_join(m49faomap, by = c("reporter" = "m49")) %>% 
  select_(~-reporter, reporter = ~fao) %>%
  do(hsInRange(.$hs, .$reporter, .$flow, 
               hsfclmap3 %>% 
                 filter(str_detect(fromcode, "^\\d+$"),
                        str_detect(tocode, "^\\d+$")),
               parallel = TRUE)) 

tlfcl %>% 
    # Mapping statistics
      group_by(id) %>% 
      mutate_(multlink = ~length(unique(fcl)) > 1,
              nolink   = ~any(is.na(fcl))) %>% 
      summarize_(multlink = ~sum(any(multlink)),
                 nolink = ~sum(any(nolink))) %>% 
  summarize_(totalrecsmulti = ~sum(multlink),
             totalnolink = ~sum(nolink),
             propmulti = ~sum(multlink) / n(),
             propnolink = ~sum(nolink) / n())
    

