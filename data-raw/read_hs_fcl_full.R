hsfclmap <- data.table::fread(file.path(Sys.getenv("HOME"),
                                     "r_adhoc",
                                     "mdb_read",
                                     "hs_fcl_full.csv"),
                           drop = c("iso2", "country", "cpc"),
                           data.table = F)

save(hsfclmap,
     file = file.path("data",
                      "hsfclmap.rdata"))
