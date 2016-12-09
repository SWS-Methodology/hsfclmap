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
  select(area, flow, hsorig, fcl = Col10)