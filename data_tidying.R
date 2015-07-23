# set working directory
if ((stringr::str_sub(getwd(), -23) == "git/Light_vs_Population") == FALSE) {
  setwd("git/Light_vs_Population")
}

# comment the next line out if you have already collected and saved the data from online sources
source("data_collection.R")

# load libraries  
library(foreign)
library(dplyr)

# get Shapefile associated .dbf data frame to merge with TopoJSON creates above
ward_dbf <- read.dbf("SHP/Wards/Wards2011.dbf")
ward_dbf$ORDER <- 0:(dim(ward_dbf)[1]-1)
town_dbf <- read.dbf("SHP/LocalMunicipalities2011.dbf")
town_dbf$ORDER <- 0:(dim(town_dbf)[1]-1)
province_dbf <- read.dbf("SHP/Province_New_SANeighbours.dbf")
province_dbf$ORDER <- 0:(dim(province_dbf)[1]-1)
# rename ID variable
ward_dbf <- rename(ward_dbf, ID = WARD_ID)

# SA_Area_SQkm <- sum(ward_dbf$Area) # South Africa's surface area in sq kilometers
# SA_Area_SQdegree_dbf <- sum(ward_dbf$Shape_Area) # South Africa's surface area in sq degrees
# 4*pi*(180/pi)^2 # earth's total area in sq degrees (for a perfect sphere)
# SA_Area_SQdegree_dbf/(4*pi*(180/pi)^2)*100 # SA's share of that sq degree surface in %
# SA_Area_SQkm /510064472*100  # SA's share of earth sq km surface in %
# # http://physics.oregonstate.edu/~hetheriw/energy/topics/doc/intro/world_area_per_person.pdf

# rename WARD_POP to VOTERS for regisitered voters in South Africa in 2011
ward_dbf <- rename(ward_dbf, VOTERS = WARD_POP)

# get ward population from Census Data and add it to ward_dbf
ward_population <- read.csv(file = "data/Population2011.csv", header = T)
ward_population <- rename(ward_population, ID = WARD)
ward_population <- rename(ward_population, POPULATION = Population)
# table(sapply(ward_population, class)) # class of variables
# sum(x = ward_population$POPULATION) # total population
ward_dbf <- merge(x = ward_dbf, y = ward_population, by = "ID")


# create munipipal population density and add it to town_dbf
town_population <- ward_dbf %>% group_by(CAT_B) %>%
  summarise(POPULATION = sum(POPULATION)) %>%
  select(CAT_B, POPULATION)
town_dbf <- merge(town_dbf, town_population, by = "CAT_B")
# sum(x = town_dbf$POPULATION) # total population
# sum(x = town_dbf$AREA) # total area

# create provincial population density and add it to province_dbf
province_population <- ward_dbf %>% group_by(PROVINCE) %>%
  summarise(POPULATION = sum(POPULATION)) %>% 
  select(PROVINCE, POPULATION)
province_dbf <- merge(province_dbf, province_population, by = "PROVINCE")
# sum(x = province_dbf$POPULATION) # total population
# sum(x = province_dbf$Area) # total area

# create population density variable
ward_dbf$DENSITY <- ward_dbf$POPULATION/ward_dbf$Area # per ward
town_dbf$DENSITY <- town_dbf$POPULATION/town_dbf$AREA # per municipality
province_dbf$DENSITY <- province_dbf$POPULATION/province_dbf$Area # per province

ward_dbf <- arrange(ward_dbf, ORDER)
town_dbf <- arrange(town_dbf, ORDER)
province_dbf <- arrange(province_dbf, ORDER)
