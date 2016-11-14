library(hsfclmap)
library(stringr)
library(dplyr, warn.conflicts = FALSE)

cores <- parallel::detectCores(all.tests = TRUE)
if(cores > 1) {
  library(foreach)
  library(doParallel)
  parallel::registerDoParallel(cores = cores)
}

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


# Printing statistics on unmapped HS codes
# and saving the codes in csv files
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



hsunmatched <- esdatafcl %>%
  filter(is.na(fcl)) %>% 
  select(area, flow, hs = hsorig) %>% 
  `<<-`(traderecordsunmatched, .) %>% 
  select(hs) %>% 
  distinct() %>% unlist %>% unname


unmappedhs <- esdatafcl %T>% 
  { cat("Total records:", nrow(.), "\n") } %>% 
  mutate(hs6 = stringr::str_extract(hsorig, "^\\d{2,6}")) %>% 
  filter(hs6 %in% hs6faointerest) %T>% 
  { cat("Total records of interest:", nrow(.), "\n") } %>% 
  filter(is.na(fcl)) %T>% 
  { cat("Records of interest with NA:", nrow(.), "\n") } %>% 
  select(hsorig) %>% 
  distinct() %T>% 
  { cat("Unique unmapped CN8 codes:", nrow(.), "\n") } %>% 
  unname %>% unlist
  
# How many unmapped HS codes when we look across all EU countries
esdatafcl %>% 
  select(-hsext) %>% 
  mutate(hs6 = stringr::str_extract(hsorig, "^\\d{2,6}")) %>% 
  filter(hsorig %in% hs6faointerest) %>% 
  group_by(hsorig) %>% 
  mutate(fclpositive = sum(!is.na(fcl))) %>% 
  ungroup() %>% 
  filter(fclpositive == 0) %>% 
  select(hsorig) %>% 
  distinct() %>% 
  nrow()