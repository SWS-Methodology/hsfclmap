hsfclmap3 <- hsfclmap2 %>% 
  # There are 2228 cases where mdb file name is CLA,
  # and it absents in Onno's register
  # But in one directory we fould mix of CLA and ECU
  # so we change CLA to ECU
  mutate(area = if_else(mdbarea == "CLA", 58L, area)) %>% 
  select(mdbyear, area, flow, fromcode, tocode, fcl) %>% 
  # Priority of records
  # Younger records have higher priority
  # New records should get biggher recordnumb value (the very
  # first record has numb 0)
  mutate(recordnumb = n() + desc(row_number())) %>% 
  # hs range can point to different fcl codes over the years
  # we want to reduce number of identical links from 
  # different years into records with year ranges
  # We can not just group by fromcode, tocode and fcl,
  # as one range can fall into another
  # and we don't want to rely on rule 
  # Shorter Range Has Priority
  # as it is better to have clearly defined separated 
  # ranges instead of overlapping ranges
  group_by(area, flow, fromcode, tocode) %>% 
  mutate(linkchange = fcl != lag(fcl),
         # first linkchange in a group is NA (no lag value), so we change it
         linkchange = if_else(is.na(linkchange), FALSE, linkchange),
         # now we convert linkchange logical into
         # a code what indentify sequencies of indentical hs ranges
         # what point to similar fcl
         # and hs ranges with one fcl but splitted over years by
         # other fcl get different linkchange code.
         # So we are able to get separate year ranges.
         linkchange = cumsum(linkchange)) %>% 
  # Min and max years of records validity
  # mdbyear indicates vilidity of a record for this year
  # For a given hs range we create 
  # startyear which is the earliest
  # endyear - the latest
  # if endyear is 2013, than it means
  # it is latest provided by B/C team
  # so we suggest this record would be valid
  # for future years and we change
  # 2013 year into far future year (2050)
  group_by(fcl, linkchange, add = TRUE) %>% 
  summarize(startyear = min(mdbyear),
            endyear   = max(mdbyear),
            # Also we extract one of record numb
            recordnumb = max(recordnumb)) %>% 
  ungroup %>% 
  mutate(endyear = if_else(endyear == 2013L, 2050L, endyear)) %>%
  select(-linkchange) %>% 
  # Some trash in fromcode
  filter(grepl("^\\d+$", fromcode)) %>% 
  mapupdate(trade2014missing %>% 
              rename(fromcode = hs), startyear = 2014L)

save(hsfclmap3, file = "data/hsfclmap3.RData", compress = "xz")
  