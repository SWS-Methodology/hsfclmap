# 2009 and above

library(dplyr, warn.conflicts = F)
library(stringr)

readitemcodesmdb <- function(filename, table) {

  
  if (!is.element(Sys.info()[["sysname"]], c("Linux", "Windows"))) 
    stop(paste0("Your OS: ", Sys.info()[["sysname"]], ". Only Windows and Linux are supported"))
  
  if (Sys.info()[["sysname"]] == "Linux") {
    
    data <- Hmisc::mdb.get(filename,
                   colClasses = "character",
                   stringsAsFactors = F,
                   lowernames = T,
                   tables = table)
    
  }
  
  if (Sys.info()[["sysname"]] == "Windows") {
    
    if(Sys.getenv("R_ARCH") != "/i386")
      stop("Please use 32 bit build of R to read mdb files in Windows.")
    
    mdbcon <- RODBC::odbcConnectAccess(filename)
    data <- RODBC::sqlFetch(mdbcon, table, as.is = TRUE, stringsAsFactors = FALSE)
    close(mdbcon)
    colnames(data) <- tolower(colnames(data))
  }
  
  data %>%
    select_(~fromcode, ~tocode, fclorig = ~faostat, ~year) %>%
    mutate_(fcl = ~as.integer(fclorig))
  
}



extractitemtable <- function(dirname) {
  # hsfclmap2 <- bind_rows(plyr::ldply("BOT_2013", function(dirname) {
  
  area <- areas_years$area[areas_years$dirnames == dirname]
  year <- areas_years$year[areas_years$dirnames == dirname]
  
  if(dirname == "CLA_2002") dirname <- "ECU_2002" # Or ecu_2000?
  if(dirname == "BYE_2013") dirname <- "AZE_2013"
  
  filename <- file.path(directory, dirname, paste0(dirname, ".mdb"))

  importtable <- "ItemCode1"
  exporttable <- "ItemCode2"

  if(dirname == "THA_2002") exporttable <- "itemcode2"
  if(dirname %in% c("THA_2003", "THA_2005", "THA_2006")) exporttable <- "Itemcode2"
  
  code1 <- readitemcodesmdb(filename, importtable)
  code2 <- readitemcodesmdb(filename, exporttable)
  
  if(area == "INS" & year == 2013) code1$tocode[code1$tocode == "4058999"] <- "40589999"
  
  areanames <- data.frame(
    area = area,
    stringsAsFactors = F)
  
  code1 <- cbind(code1, areanames, flow = "Import", mdbyear = year, stringsAsFactors = F)
  code2 <- cbind(code2, areanames, flow = "Export", mdbyear = year, stringsAsFactors = F)
  
  if("FALSE" %in% code1$area) message(paste0(dirname, " code1 ", sum(df$area == "FALSE")))
  if("FALSE" %in% code2$area) message(paste0(dirname, " code2 ", sum(df$area == "FALSE")))
  
  df <- bind_rows(code1, code2) %>% as.data.frame
  # df <- bind_rows(code1, code2, stringsAsFactors = F) %>% as.data.frame
  
  df
  
}

# directory <- file.path("", "mnt", "essdata", "TradeSys", "TradeSys", "Countries")
directory <- file.path(Sys.getenv("HOME"), "Downloads", "Countries")
startyear <- 1946

areas_years <- data.frame(dirnames = dir(directory, full.names = F), stringsAsFactors = F) %>%
  filter(str_detect(dirnames, "^[A-Z]{3}_[1-2][0-9]{3}$")) %>%
  mutate(area = str_extract(dirnames, "^[A-Z]{3}"),
         year = as.integer(str_extract(dirnames, "[1-2][0-9]{3}$"))) %>%
  filter(year >= startyear)


hsfclmap2 <- bind_rows(plyr::ldply(areas_years$dirnames, 
                                   extractitemtable, 
                                   .progress = "text",
                                   .inform = FALSE))

## Read area codes / names from Onno's map


codes <- XLConnect::readWorksheetFromFile(file.path("data-raw",
                                                    "Trade_Country-Registry.xlsx"),
                                          header = T,
                                          sheet = "Sheet1",
                                          endCol = 2)
codes$Acronyme <- toupper(codes$Acronyme)
names(codes) <- tolower(names(codes))
codes <- rbind(codes, c("VIE", 237))

hsfclmap2 <- hsfclmap2 %>%
  left_join(codes %>%
              rename_(faoarea = ~fao_code),
            by = c("area" = "acronyme")) %>%
  rename_(mdbarea = ~area,
          area = ~faoarea,
          mdbfcl = ~fclorig) %>%
  mutate(area = as.integer(area),
         validyear = ifelse(year == "", 0L, as.integer(year))) %>%
  mutate_(validyear = ~ifelse(validyear == 0L, NA, validyear)) %>%
  select(-year) %>%
  distinct_() %>%
  # Removing leading/trailing zeros from HS, else we get
  # NA during as.numeric()
  mutate_each_(funs = funs(str_trim),
               vars = c("fromcode", "tocode")) %>%
  # Convert flow to numbers for further joining with tlmaxlength
  mutate_(flow = ~ifelse(flow == "Import", 1L,
                         ifelse(flow == "Export", 2L,
                                NA))) %>%
  ## Manual corrections of typos
  hsfclmap::manualCorrections() %>%
  select_(~validyear, ~area, ~flow, ~fromcode, ~tocode, ~fcl, ~mdbyear, ~mdbarea, ~mdbfcl)

save(hsfclmap2,
     file = file.path("data",
                      "hsfclmap2.RData"),
     compress = "xz")
