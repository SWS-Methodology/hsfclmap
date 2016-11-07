library(stringr)
library(dplyr, warn.coflicts = FALSE)

esdataorig <- loadesdata(file.path(
  Sys.getenv("HOME"), 
  "ce_combinednomenclature_unlogged_2013.csv.gz"))

esdata13 <- esdata2faoarea(esdataorig, loadgeonom())

esmpl <- 10^5

esdatafcl <- esdata %>% 
  sample_n(smpl) %>% 
  do(hsInRange(.$hs, .$reporter, .$flow, 
               hsfclmap3 %>% 
                 filter(str_detect(fromcode, "^\\d+$")))) 
  

nrow(esdatafcl) / smpl

sum(is.na(esdatafcl$fcl)) / nrow(esdatafcl)

sum(!unique(hsfclmap3$fcl) %in% unique(esdatafcl$fcl)) / length(unique(hsfclmap3$fcl))

save(list = c("esdata", "esdatafcl", "esdataorig"), 
     file = file.path(Sys.getenv("HOME"), 
                      "estrade13_14.RData"),
     compress = "xz")
     