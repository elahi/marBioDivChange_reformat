#################################################
# Reformat CB data for Maria Dornelas, and sDiv working group
# Author: Robin Elahi
# Date: 150221
#################################################
# Change Log
# 150223 - reformatted data again

rm(list=ls(all=TRUE)) # removes all previous material from R's memory

##### LOAD PACKAGES #####
library(dplyr)
library(tidyr)

##### MASTER DATASET #####
fullDat <- read.csv("./data/TableS4.csv", header=TRUE, na.strings="NA")
names(fullDat)
unique(fullDat$studyName)
unique(fullDat$studySub)
unique(fullDat$subSiteID)

# Select columns and rename
fullDat <- fullDat %>%
  select(site, studySub, studyName, subSiteID, Scale, dateR, rich, div, 
         abund, AbundUnitsOrig)
head(fullDat)

fullDat$study_sub_site <- with(fullDat, paste(studyName, studySub, site, sep = "-"))
unique(fullDat$study_sub_site)
unique(fullDat$studyName)

##### STUDIES #####
studies <- read.csv("./data/studyNameList.csv", header=TRUE, na.strings="NA") 
names(studies)

# Select columns and rename
studies <- studies %>% 
  select(studyName, Reference_dunic, FigsTables, Collector, Sys_dunic, Loc) %>%
  rename(Reference = Reference_dunic, Source = FigsTables, Sys = Sys_dunic)
head(studies)

##### SUB-STUDIES #####
subStudies <- read.csv("./data/studySubList.csv", header=TRUE, na.strings="NA")
names(subStudies)
# Select columns and rename
subStudies <- subStudies %>%
  select(studyName:Descriptor.of.Taxa.Sampled, Vis:PltN, SiAreaCalc, 
         SiLinearExtentUnits, RepeatType)
names(subStudies)

##### SITES #####
sites <- read.csv("./data/siteList.csv", header=TRUE, na.strings="NA")
names(sites)

# Select columns and rename
sites <- sites %>% 
  select(studyName, site, Event, Driver, Prediction, EventDate1, EventDate2, 
         Lat, Long, Depth_m) 
head(sites)

### Create 'Year of Event' column
# translate dates to R 
sites$event1 <- as.Date(sites$EventDate1, origin="1900-01-01")
sites$event2 <- as.Date(sites$EventDate2, origin="1900-01-01")
# check to make sure that 1998 El Nino was in fact in 1998 (use origin = "1904-01-01" if not)

head(sites)
str(sites)

# Get year from date object
sites$event1yr <- as.numeric(format(sites$event1, '%Y'))
sites$event2yr <- as.numeric(format(sites$event2, '%Y'))

# create "Year of event" column
sites$Year_of_Event <- with(sites, ifelse(is.na(event2yr) == "TRUE", 
                                          event1yr, 
                                          paste(event1yr, ",", event2yr)))
head(sites)
unique(sites$Event_type)

# select new columns
sites2 <- sites %>%
  select(studyName, site, Event, Driver, Lat, Long, Year_of_Event, Depth_m)
head(sites2)

##### MERGE STUDIES, SUB-STUDIES, SITES #####
### Merge studies and sub-studies
dat1 <- right_join(studies, subStudies, by = "studyName")
head(dat1)

dat2 <- right_join(studies, sites2, by = "studyName") %>%
  select(studyName, site:Depth_m)
dat2$study_site <- with(dat2, paste(studyName, site, sep = "-"))
head(dat2)

dat3 <- right_join(dat1, dat2, by = "studyName")
head(dat3)

# GSUB to switch BirkeSC to SC
unique(dat3$site)
site2 <- dat3$site
dat3$Site <- gsub("BirkeSC", "SC", site2)
dat3 %>% filter(crap2 == "SC")

dat3$study_sub_site <- with(dat3, paste(studyName, studySub, Site, sep = "-"))
unique(dat3$study_sub_site)

# remove irrelevant studies not used in CB paper
unique(fullDat$studyName)
unique(dat3$studyName)

dat4 <- dat3 %>% 
  filter(studyName != "Bebars" & studyName != "Keller" & 
           studyName != "Greenwood" & studyName != "Sonnewald" &
           studyName != "SwedFishTrawl")
unique(dat4$studyName)

dat4 <- droplevels(dat4)

# Compare details with richness data
with(dat4, unique(studyName))
with(fullDat, unique(studyName))

with(dat4, unique(studySub))
with(fullDat, unique(studySub))

with(dat4, unique(site))
with(fullDat, unique(site))

with(dat4, unique(study_sub_site))
with(fullDat, unique(study_sub_site))

# Rename
master_details <- dat4
head(master_details)

##### MERGE DETAILS WITH RICHNESS DATA #####
names(master_details)
names(fullDat)
fullDat$site

# drop redundant columns in one dataset
fullDat2 <- fullDat %>% select(-studyName, -site, -studySub)

master <- left_join(fullDat2, master_details, by = "study_sub_site")
names(master)

##### SUBSET COLUMNS FOR MARIA #####
master2 <- master %>% select(studyName, studySub, subSiteID, Lat, Long, dateR, 
                             rich, div, abund, AbundUnitsOrig, Scale,  
                             study_sub_site, Site, 
                             Driver, Year_of_Event, Depth_m, RepeatType)

master2 <- droplevels(master2)
head(master2)

master2$sample_id <- with(master2, 
                          paste(studySub, "_", Site, "_", Scale, sep = ""))

unique(master2$sample_id)

head(master2)

##### REMOVE GAMMA TIME-SERIES THAT ARE ALREADY REPRESENTED BY ALPHA #####
names(master2)
unique(master2$Scale)
unique(master2$subSiteID)
unique(master2$studySub)
unique(master2$studyName)

master2 %>% filter(Scale == "alpha") %>% summarise(length = n())
master2 %>% filter(Scale == "gamma") %>% summarise(length = n())

study_scale_DF <- as.data.frame.matrix(with(master2, table(study_sub_site, Scale)))
head(study_scale_DF)
study_scale_DF$study_sub_site <- rownames(study_scale_DF)

study_scale_DF$bothScales <- study_scale_DF$alpha > 0 & study_scale_DF$gamma > 0

master3 <- left_join(master2, study_scale_DF, by = "study_sub_site")
head(master3)

master3$bothScales == "TRUE" & master3$Scale == "gamma"

master3$remove <- ifelse(master3$bothScales == "TRUE" & 
                           master3$Scale == "gamma", 'remove', 'keep')


masterSub <- master3 %>% filter(remove == "keep") %>% droplevels()

unique(masterSub$subSiteID)

### Do the subsetting and renaming
names(masterSub)

# Database
masterSub$Database <- "Elahi"

# DepthElevation
masterSub$dateR <- as.Date(as.character(masterSub$dateR))

masterSub$Day <- as.numeric(format(masterSub$dateR, "%d"))
masterSub$Month <- as.numeric(format(masterSub$dateR, "%m"))
masterSub$Year <- as.numeric(format(masterSub$dateR, "%Y"))

# Genus, Species
masterSub$Genus <- NA
masterSub$Species <- NA

# ObsEventID
names(masterSub)
masterSub$ObsEventID <- with(masterSub, paste(studySub, Site, 
                                              Lat, Long, "NA",
                                              Year, Month, Day, sep = "_"))

# ObsID
names(masterSub)
masterSub$ObsID <- with(masterSub, paste(studySub, Site, 
                                              Lat, Long, "NA", sep = "_"))

head(masterSub)

# Treatment
masterSub$Treatment <- NA

names(masterSub)

# Rename: CitationID, StudyID, Latitude, Longitude, DepthElevation

masterSub2 <- masterSub %>% rename(CitationID = studyName,
                                   StudyID = studySub, 
                                   Latitude = Lat, 
                                   Longitude = Long, 
                                   DepthElevation = Depth_m)

names(masterSub2)

masterSub3 <- masterSub2 %>% select(Database, CitationID, StudyID, 
                                    Site, Latitude, Longitude, 
                                    DepthElevation, Day, Month, Year, 
                                    Genus, Species, ObsEventID, ObsID, 
                                    RepeatType, Treatment,
                                    rich, div, abund, 
                                    AbundUnitsOrig)

head(masterSub3)

### Put rich, div, abund in one column (make dataset longer)
# Can't use gather, because richness and div are not evenly distributed
# So, split the datasets apart first
richDat <- droplevels(masterSub3[complete.cases(masterSub3$rich), ])
richDat <- richDat %>% rename(Value = rich) %>% select(-div, -AbundUnitsOrig, -abund)
richDat$ValueType <- "richness"
richDat$ValueUnits <- NA
head(richDat)

divDat <- droplevels(masterSub3[complete.cases(masterSub3$div), ])
divDat <- divDat %>% rename(Value = div) %>% select(-rich, -AbundUnitsOrig, -abund)
divDat$ValueType <- "shannon"
divDat$ValueUnits <- NA
head(divDat)

abundDat <- droplevels(masterSub3[complete.cases(masterSub3$abund), ])
abundDat <- abundDat %>% rename(Value = abund, ValueUnits = AbundUnitsOrig) %>% 
  select(-rich, -div)

unique(abundDat$ValueUnits)

ValueType <- abundDat$ValueUnits

leftText <- function(x, n) {
  substr(x, 1, n) 
}

vt2 <- leftText(ValueType, 5)
unique(vt2)

vt3 <- gsub("indiv", "abundance", vt2)
vt4 <- gsub("Perce", "cover", vt3)
vt5 <- gsub("metri", "biomass", vt4)
vt6 <- gsub("kgPer", "biomass", vt5)

unique(vt6)

abundDat$ValueType <- vt6


names(richDat)
names(divDat)
names(abundDat)

### Now rbind it
masterL <- rbind(richDat, divDat, abundDat)
head(masterL)

unique(masterL$StudyID)
unique(masterL$ObsID)
unique(masterL$ValueType)
unique(masterL$ValueUnits)

summary(masterL)

unique(masterL$ValueType)

write.csv(masterL, "./output/elahi_biotime.csv")
