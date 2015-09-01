library(dplyr)
library(stringr)

hsfclmap <- data.table::fread(file.path(Sys.getenv("HOME"),
                                     "r_adhoc",
                                     "mdb_read",
                                     "hs_fcl_full.csv"),
                           drop = c("iso2", "country", "cpc"),
                           data.table = F) %>%
  mutate_each(funs(str_trim), ends_with("code"))


    # Add variables, compare them and calculate required number of zeros

save(hsfclmap,
     file = file.path("data",
                      "hsfclmap.rdata"))
