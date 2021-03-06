#################################################
# Reformat CB data for Jillian Dunic
# Author: Robin Elahi
# Date: 150114
#################################################

rm(list=ls(all=TRUE)) # removes all previous material from R's memory

##### LOAD PACKAGES #####
library(dplyr)
library(tidyr)

##### MASTER DATASET #####
fullDat <- read.csv("./data/TableS4.csv", header=TRUE, na.strings="NA")
names(fullDat)

# Select columns and rename
fullDat <- fullDat %>%
  select(site, studySub, studyName, subSiteID, Scale, dateR, rich, div, 
         abund, AbundUnitsOrig)
head(fullDat)

fullDat$study_sub_site <- with(fullDat, paste(studyName, studySub, site, sep = "-"))
unique(fullDat$study_sub_site)

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

# Select columns and rename
subStudies <- subStudies %>%
  select(studyName:Descriptor.of.Taxa.Sampled, Vis:PltN, SiAreaCalc, 
         SiLinearExtentUnits)
names(subStudies)

##### SITES #####
sites <- read.csv("./data/siteList.csv", header=TRUE, na.strings="NA")
names(sites)

# Select columns and rename
sites <- sites %>% 
  select(studyName, site, Event, Driver, Prediction, EventDate1, EventDate2, 
         Lat, Long) %>%
  rename(Event_type = Driver)
head(sites)

# Create 'A priori' column
sites$A_priori <- with(sites, ifelse(Prediction == "none", "No", "Yes"))

# Modify event column
sites$Event <- with(sites, ifelse(Event == "yes", "Yes", "No"))
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

# select new columns
sites2 <- sites %>%
  select(studyName, site, Event, Event_type, Lat, Long, A_priori, Year_of_Event)
head(sites2)

##### MERGE STUDIES, SUB-STUDIES, SITES #####
head(studies)
head(subStudies)
head(sites2)

names(studies)
names(subStudies)
names(sites2)

### Merge studies and sub-studies
dat1 <- right_join(studies, subStudies, by = "studyName")
head(dat1)

dat2 <- right_join(studies, sites2, by = "studyName") %>%
  select(studyName, site:Year_of_Event)
dat2$study_site <- with(dat2, paste(studyName, site, sep = "-"))
head(dat2)

dat3 <- right_join(dat1, dat2, by = "studyName")
head(dat3)

dat3$study_sub_site <- with(dat3, paste(studyName, studySub, site, sep = "-"))
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

# drop redundant columns in one dataset
fullDat2 <- fullDat %>% select(-studyName, - studySub, -site)

master <- left_join(fullDat2, master_details, by = "study_sub_site")
names(master)

write.csv(master, './output/master.csv')
