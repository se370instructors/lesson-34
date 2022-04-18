#---Lesson 34: Geospatial Analysis I
#-By: Ian Kloo
#-April 2022

library(readr)
library(dplyr)
library(ggplot2)
#install.packages(c('rnaturalearth', 'rnaturalearthdata'))
library(rnaturalearth)
library(rnaturalearthdata)
library(sf)
library(leaflet)

#---Static Mapping with ggplot---#

#start with some data with starbucks locations with lat/lon
df <- read_csv('Starbucks.csv')

#drop anything without valid coordinates


#just the US


#lets try to plot!


#that works to get the general shape ...but the world isn't flat (sorry Kyrie)
#it is easier to see the distortion effect when plotting the whole world:


#to map the round earth to a flat surface, we have to use projections
#there are many different projections you can use that have different properties: https://bl.ocks.org/syntagmatic/raw/ba569633d51ebec6ec6e/?raw=true

#we will get into projections and CRFs (Coordinate Reference Systems) in later lessons
#for now, let's read in a pre-built SF object: https://r-spatial.github.io/sf/
world <- ne_countries(scale = "medium", returnclass = "sf")
class(world)

#this looks like a dataframe, but note the "geometry" column.  this holds the shapes of each country
#we can plot them with ggplot!


#you can mess around with the aesthetics


#now we can map our points:


#similarly, you can mess with the aesthetics


#what if we just want to plot the US?
#we could narrow down what coordinate bounds


#we might want to get more detail if we're just interested in the US
#to get state bounds, we can go to the census: https://www.census.gov/geographies/mapping-files/time-series/geo/carto-boundary-file.html
usa <- sf::read_sf('cb_2018_us_state_20m')

#this data format is called "shapefile" and it is commonly stored in a folder.  here we just tell R where the folder is located and it
#uses the files it needs to construct the SF object


#we probably want to drop the OCONUS stuff from the geospatial data and the starbucks data
#how do we know the FIPS codes? https://www.nrcs.usda.gov/wps/portal/nrcs/detail/?cid=nrcs143_013696


#let's keep narrowing down - now to NY state


#that's OK, but we probably want the county-level census data now:
#this is the whole country with county lines



#subsetting to NYS



#points are useful, but sometimes it is useful to plot what is called a "choropleth" map that colors an entire area based on some attribute
#let's use county population: https://www.census.gov/data/datasets/time-series/demo/popest/2010s-counties-total.html#par_textimage_70769902
df_pop <- read_csv('co-est2019-alldata.csv')

#we only care about the census population in 2010, let's just do NY


#joining our population data to the geospatial data (note the order for the join)


#might be more interesting with a log-scaled fill


#or some different colors


#---Exercise---#
#1. webscrape the average annual temperatures from wikipedia: https://en.wikipedia.org/wiki/List_of_countries_by_average_yearly_temperature
#2. drop any records that don't come in as numeric
#3. join the temp data with the 'world' data we read in earlier 
#4. create choropleth maps for africa and south america using temperature as your feature
#5. bonus: change your scale so that hotter countries are dark read and cooler countries are light red

library(rvest)





