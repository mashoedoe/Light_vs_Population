# set working directory
if ((stringr::str_sub(getwd(), -23) == "git/Light_vs_Population") == FALSE) {
  setwd("git/Light_vs_Population")
}
# load libraries  
library(downloader)

# create directories for the Shapefiles that we will download, unzip, unrar & transform to TopoJSON
if (!dir.exists("TopoJSON")) dir.create("TopoJSON")
if (!dir.exists("SHP")) dir.create("SHP")
if (!dir.exists("data")) dir.create("data")

# if (!file.exists("SHP/Wards2011")) {
#     download(url = "http://www.demarcation.org.za/index.php/downloads/boundary-data/boundary-data-main-files/wards/11457-wards/file",
#          destfile = "SHP/Wards2011")
# }
# if (!file.exists("SHP/LocalMunics2011")) {
# download(url = "http://www.demarcation.org.za/index.php/downloads/boundary-data/boundary-data-main-files/local-munics/11453-local-munics/file",
#          destfile = "SHP/LocalMunics2011")
# }
# if (!file.exists("SHP/Province2011")) {
# download(url = "http://www.demarcation.org.za/index.php/downloads/boundary-data/boundary-data-main-files/province/11456-province/file",
#          destfile = "SHP/Province2011")
# }

# create temporary directory to download zipped shapefiles into
tempdir <- tempdir()

# if data files not already installed, down load them to the  temporary directory
if (!dir.exists("SHP/Wards") & !file.exists("SHP/LocalMunicipalities2011.dbf") & 
    !file.exists("SHP/LocalMunicipalities2011.prj") & !file.exists("SHPLocalMunicipalities2011.sbn") & 
    !file.exists("SHP/LocalMunicipalities2011.sbx") & !file.exists("SHP/LocalMunicipalities2011.shp") & 
    !file.exists("SHP/LocalMunicipalities2011.shp.xml") & !file.exists("SHP/LocalMunicipalities2011.shx") &
    !file.exists("SHP/Province_New_SANeighbours.dbf") & !file.exists("SHP/Province_New_SANeighbours.prj") & 
    !file.exists("SHP/Province_New_SANeighbours.sbn") & !file.exists("SHP/Province_New_SANeighbours.sbx") & 
    !file.exists("SHP/Province_New_SANeighbours.shp") & !file.exists("SHP/Province_New_SANeighbours.shp.xml") & 
    !file.exists("SHP/Province_New_SANeighbours.shx")) {

  # download zipped Ward, Municipal & Provincial Level Shapefiles for South Africa from the Municipal Demarcation Board
  download(url = "http://www.demarcation.org.za/index.php/downloads/boundary-data/boundary-data-main-files/wards/11457-wards/file",
          destfile = paste0(tempdir, "/Wards2011"))
  download(url = "http://www.demarcation.org.za/index.php/downloads/boundary-data/boundary-data-main-files/local-munics/11453-local-munics/file",
          destfile = paste0(tempdir, "/LocalMunics2011"))
  download(url = "http://www.demarcation.org.za/index.php/downloads/boundary-data/boundary-data-main-files/province/11456-province/file",
          destfile = paste0(tempdir, "/Province2011"))
}
# unzip Ward Shapefiles & transfer to SHP folder
if (!dir.exists("SHP/Wards")) {unzip(zipfile = paste0(tempdir, "/Wards2011"), exdir = "SHP/")}

# unzip & unrar Municipal Shapefiles & transfer to SHP folder
if (!file.exists("SHP/LocalMunicipalities2011.dbf") & !file.exists("SHP/LocalMunicipalities2011.prj") &
    !file.exists("SHPLocalMunicipalities2011.sbn") & !file.exists("SHP/LocalMunicipalities2011.sbx") & 
    !file.exists("SHP/LocalMunicipalities2011.shp") & !file.exists("SHP/LocalMunicipalities2011.shp.xml") & 
    !file.exists("SHP/LocalMunicipalities2011.shx")) {
  
  unzip(zipfile = paste0(tempdir, "/LocalMunics2011"), exdir = tempdir)
  try(system(command = paste0("unrar x ","'",tempdir,"/Local Munics1/LocalMunics.rar","'"," SHP/"))) 
}
# unzip & unrar Provincial Shapefiles & transfer to SHP folder
if (!file.exists("SHP/Province_New_SANeighbours.dbf") & !file.exists("SHP/Province_New_SANeighbours.prj") & 
    !file.exists("SHP/Province_New_SANeighbours.sbn") & !file.exists("SHP/Province_New_SANeighbours.sbx") & 
    !file.exists("SHP/Province_New_SANeighbours.shp") & !file.exists("SHP/Province_New_SANeighbours.shp.xml") & 
    !file.exists("SHP/Province_New_SANeighbours.shx")) {
  
  unzip(zipfile = paste0(tempdir, "/Province2011"), exdir = tempdir)
  try(system(command = paste0("unrar x ",tempdir,"/Province/Province.rar"," SHP/")))
}

# convert shapefiles to topoJSON files using MAPSHAPER at the command line, 
# removing 90% of polygon points with the Douglas–Peucker algorithm
# this can also be done manually at with an online GUI at http://www.mapshaper.org/
if (!file.exists("TopoJSON/LocalMunicipalities2011.json") & !file.exists("TopoJSON/Province_New_SANeighbours.json")) {
  try(system(command = paste0("mapshaper -i auto-snap SHP/*.shp -simplify dp 10% keep-shapes -o ",getwd(),"/TopoJSON format=topojson"), 
             intern = T, ignore.stdout = F, ignore.stderr = F))
}

if (!file.exists("TopoJSON/Wards2011.json")) {
  try(system(command = paste0("mapshaper -i auto-snap SHP/Wards/*.shp -simplify dp 10% keep-shapes -o ",getwd(),"/TopoJSON format=topojson"), 
             intern = T, ignore.stdout = F, ignore.stderr = F))
}

# save any data you select and download from http://interactive.statssa.gov.za/superweb/login.do in the "data" directory 

# remove temporary directory
unlink(tempdir)
rm(tempdir)