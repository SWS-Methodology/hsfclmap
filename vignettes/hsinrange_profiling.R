library(stringr)
library(dplyr, warn.coflicts = FALSE)
library(foreach)
library(doParallel)
registerDoParallel(cores = detectCores(all.tests = TRUE))

esdataorig <- loadesdata(file.path(
  Sys.getenv("HOME"), 
  "ce_combinednomenclature_unlogged_2014.csv.gz"))

esdata14 <- esdata2faoarea(esdataorig, loadgeonom())

smpl <- 10^5

esdatafcl14 <- esdata14 %>% 
  sample_n(smpl) %>% 
  do(hsInRange(.$hs, .$reporter, .$flow, 
               hsfclmap3 %>% 
                 filter(str_detect(fromcode, "^\\d+$")),
               parallel = TRUE)) 
  
esdatafcl <- esdatafcl14

nrow(esdatafcl) / smpl

sum(is.na(esdatafcl$fcl)) / nrow(esdatafcl)

sum(unique(hsfclmap3$fcl) %in% 
      unique(esdatafcl$fcl)) / 
  length(unique(hsfclmap3$fcl))

length(unique(hsfclmap3$fcl))
length(unique(esdatafcl$fcl))

esdatafcl %>% 
  group_by(id) %>% 
  summarize(manyfcl = length(unique(fcl)) > 1) %>% 
  ungroup() %>% 
  summarize(sum(manyfcl) / n())

esdatafcl %>% 
  group_by(id) %>% 
  summarize(nofcl = any(is.na(fcl))) %>% 
  ungroup() %>% 
  summarize(sum(nofcl)/n())

esdatafcl %>% 
  group_by(area, id) %>% 
  summarize(nofcl = any(is.na(fcl))) %>% 
  group_by(area) %>% 
  summarize(nofclprop = sum(nofcl)/n()) %>% 
  ungroup() %>% 
  arrange(desc(nofclprop))