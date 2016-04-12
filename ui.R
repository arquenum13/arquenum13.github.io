library(htmlwidgets)
library(shiny)
library(leaflet)
library(RJSONIO)
library(rgdal)
library(maptools)

# Loading data from the website
addy="http://opendata.dc.gov/datasets/bda20763840448b58f8383bae800a843_26.geojson?"
crime.json <- fromJSON(addy, simplify=TRUE)

#Post extraction from JSON do summary() on list (crime.json) to identify the node for extraction
tmp <-crime.json[['features']]

#Data extraction functions
grabInfoA<-function(val){
  l<- length(tmp[[1]][[val]])
  tmp<-lapply(1:l, function(y) 
    sapply(tmp, function(x){
      if(!is.null(x[[val]][[y]])){
        return(x[[val]][[y]])
      }else{
        return(NA)
      }}))}
grabInfoB<-function(val,val2){
  l<- length(tmp[[1]][[val]][[val2]])
  tmp<-lapply(1:l, function(y) 
    sapply(tmp, function(x){
      if(!is.null(x[[val]][[val2]][[y]])){
        return(x[[val]][[val2]][[y]])
      }else{
        return(NA)
      }}))}

#Pulling data out of nested list and combining into a data frame
a<-data.frame(grabInfoA(2))
b<-data.frame(grabInfoB(3,2))
names(a)<-names(tmp[[1]]$properties)
names(b)<-c("coords.x1","coords.x2")
dcMap2 <- cbind(a,b)

#extrating the last modified date
lMod <- format(as.Date(as.POSIXlt(dcMap2$LASTMODIFIEDDATE[1])), format="%B %d, %Y") 

#Criminal Offense list
off <- c("ARSON", "ASSAULT W/DANGEROUS WEAPON", "BURGLARY", "HOMICIDE", "MOTOR VEHICLE THEFT", "ROBBERY", "SEX ABUSE","THEFT F/AUTO", "THEFT/OTHER")

# Marker color list
cMarker <- c("pink", "blue", "green","orange", "black","yellow", "gray", "purple", "red")

ui <- fluidPage(
  h1(paste("DC 2016 Crime Report (Data as of ", as.character(lMod), ")")),
  #p(),
  # Copy the line below to make a select box
  #selectInput("offense", label = h3("Select Offense"), choices=attributes(dcMap2$OFFENSE),selected = "ARSON"),
  selectInput("offense", label = h3("Select Offense"), 
              choices = list("Arson" = "ARSON", "Assault with Dangerous Weapon" = "ASSAULT W/DANGEROUS WEAPON", 
                             "Burglary" = "BURGLARY", "Homicide" = "HOMICIDE", "Motor Vehicle Theft" = "MOTOR VEHICLE THEFT", 
                             "Robbery" = "ROBBERY", "Sex Abuse" = "SEX ABUSE", "Theft from Motor Vehicle" = "THEFT F/AUTO", 
                             "General Theft" = "THEFT/OTHER", "Show All" = "Show All"), 
              selected = "ASSAULT W/DANGEROUS WEAPON"),
  leafletOutput("m", width = "1600px", height = "900px")
)
