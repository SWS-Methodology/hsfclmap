library(hsfclmap)
library(stringr)
library(dplyr, warn.conflicts = FALSE)
library(foreach)
library(doParallel)
registerDoParallel(cores = detectCores(all.tests = TRUE))

esdata14 <- loadesdata(file.path(
  Sys.getenv("HOME"), 
  "ce_combinednomenclature_unlogged_2014.csv.gz"))

esdata14 <- esdata2faoarea(esdata14, loadgeonom())

esmpl <- 10^5

esdatafcl14 <- esdata14 %>% 
  # sample_n(smpl) %>% 
  do(hsInRange(.$hs, .$reporter, .$flow, 
               hsfclmap3 %>% 
                 filter(str_detect(fromcode, "^\\d+$"),
                        str_detect(tocode, "^\\d+$")),
               parallel = FALSE)) 

save("esdatafcl14", 
     file = file.path(Sys.getenv("HOME"), 
                      "esdatafcl14.RData"),
     compress = "xz")

esdatafcl <- esdatafcl14

nrow(esdatafcl) / smpl

sum(is.na(esdatafcl$fcl)) / nrow(esdatafcl)

sum(!unique(hsfclmap3$fcl) %in% unique(esdatafcl$fcl)) / length(unique(hsfclmap3$fcl))

save(list = c("esdata", "esdatafcl", "esdataorig"), 
     file = file.path(Sys.getenv("HOME"), 
                      "estrade13_14.RData"),
     compress = "xz")
     
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
  summarize(sum(nofcl)/n()) %>% unlist %>% unname

esdatafcl %T>%
{print(paste("Total number of trade records:", 
             nrow(.)))} %T>% 
  {print(paste("Unique HS codes:", 
                length(unique(.$hsorig))))} %>% 
  filter(is.na(fcl)) %>% 
  select(faoarea = area, flow, hs = hsorig) %>% 
  arrange(faoarea, flow, hs) %T>%
  {print(paste(
    "Number of records with unmatched HS codes:",
    nrow(.)))} %T>% 
  write.csv(file = "esdata2014_nofcl.csv",
            row.names = FALSE) %>% 
  select(hs) %>% 
  distinct() %T>% 
  {print(paste("Unique unmatched HS codes:",
               nrow(.)))} %>% 
  write.csv(
    file = "esdata2014_nofcl_unique_hs.csv",
    row.names = FALSE)


