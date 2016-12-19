# Please find attached a first set of CN8 codes that we need your team's input.
# 
# As you are aware Alex is de-bugging the function re-maps HS-tariff line codes to the FCL-CPC from the
# +previous .mdb files. He built by the same token a lists of unmapped codes - attached herewith.
# 
# The file contains 265 unique unmatched codes found in Eurostat's 2014 trade file, which need a new
# +correspondence to the FCL-CPC. Country codes are per FAOSTAT list of countries.
# 
# I would be grateful if you could provide the mapping by Friday 9 December, so that by the end of the
# +week the trade module can run on full and correct item correspondences.
# 

es2014missing <- XLConnect::readWorksheetFromFile(file.path("data-raw",
                                                    "missinglinks2014.xlsx"),
                                          header = T,
                                          sheet = "nolinks",
                                          endCol = 10L,
                                          endRow = 266L) %>% 
  select(area, flow, hs = hsorig, fcl = Col10) %>% 
  mutate_at(c("area", "flow", "fcl"), as.integer)



# Claudia
# Date: Thu, 15 Dec 2016 14:40:30 +0000
# 
# Apart from Canada, please find attached the missing links you sent us. Please note that where I put NO
# +the country file could be wrong (eg see 169 Paraguay). 

tl2014missing <- XLConnect::readWorksheetFromFile(
  file.path("data-raw",
            "missinglinks_tariffline_2014.xlsx"),
  header = T,
  sheet = "Sheet1") %>% 
  rename(fcl = FCL) %>% 
  filter(fcl != "NO") %>% 
  mutate_at(c("area", "flow", "fcl"), as.integer)

trade2014missing <- bind_rows(
  tl2014missing, es2014missing) %>% 
  mutate(hs = as.character(format(hs, scientific = FALSE)),
         hs = stringr::str_trim(hs)) %>% 
  as.tbl

rm(tl2014missing, es2014missing)

save(trade2014missing, file = "data/trade2014missing.RData")
