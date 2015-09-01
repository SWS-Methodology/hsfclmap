hsInRange <- function(hs, areacode, flowname, mapdataset, calculation = "grouping",
                      parallel = F) {

  if(!all.equal(length(hs), length(areacode), length(flowname))) stop("Vectors of different length")

  if(calculation == "grouping") {
    df <- data.frame(hs = hs,
                     areacode = areacode,
                     flowname = flowname,
                     stringsAsFactors = F)

    df_fcl <- plyr::ddply(df,
                          .variables = c("areacode", "flowname"),
                          .fun = function(subdf) {
                            mapdataset <- mapdataset %>%
                              filter(fao == areacode[1],
                                     flow == flowname[1])

                            if(nrow(mapdataset) == 0) return(rep.int(as.character(NA),
                                                                     times = seq_len(nrow(subdf))))

                            fcl <- vapply(seq_len(nrow(subdf)),
                                          FUN = function(i) {

                                            hs <- subdf[i, "hs"]

                                            mapdataset <- mapdataset %>%
                                              filter(fromcode <= hs &
                                                       tocode >= hs)

                                            if(nrow(mapdataset) == 0) return(as.character(NA))

                                            mapdataset %>%
                                              select(fcl) %>%
                                              unlist %>%
                                              '[['(1)
                                          },
                                          FUN.VALUE = character(1)
                            )

                            data.frame(hs = subdf$hs, fcl = fcl, stringsAsFactors = F)
                          },
                          .parallel = parallel)

    original_n <- nrow(df)
    if(original_n != nrow(df_fcl)) warning("Not equal before joining!")

    df <- df %>% left_join(df_fcl,
                     by = c("hs", "areacode", "flowname"))

    if(nrow(df) != original_n) warning("Not equal after joining!")

    df

  }
}
