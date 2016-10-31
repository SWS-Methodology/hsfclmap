library(magrittr)
library(dplyr, warn.conflicts = FALSE)

data("hsfclmap2", package = "hsfclmap")

hsfclmap3 <- hsfclmap2 %>% 
  select(area, flow, fromcode, tocode, fcl, startyear = validyear) %T>% 
  {nrow(.) %>% print} %>% 
  distinct() %T>% 
  {nrow(.) %>% print} 


save(hsfclmap3,
     file = file.path("data",
                      "hsfclmap3.RData"),
     compress = "xz")