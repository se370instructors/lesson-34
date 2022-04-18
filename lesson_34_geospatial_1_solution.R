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
df <- df %>%
  filter(!is.na(Latitude) | !is.na(Longitude))

#just the US
df_usa <- df %>% 
  filter(Country == 'US')

#lets try to plot!
ggplot(df_usa, aes(x = Longitude, y = Latitude)) + geom_point() + theme_void()

#that works to get the general shape ...but the world isn't flat (sorry Kyrie)
#it is easier to see the distortion effect when plotting the whole world:
ggplot(df, aes(x = Longitude, y = Latitude)) + geom_point() + theme_void()

#to map the round earth to a flat surface, we have to use projections
#there are many different projections you can use that have different properties: https://bl.ocks.org/syntagmatic/raw/ba569633d51ebec6ec6e/?raw=true

#we will get into projections and CRFs (Coordinate Reference Systems) in later lessons
#for now, let's read in a pre-built SF object: https://r-spatial.github.io/sf/
world <- ne_countries(scale = "medium", returnclass = "sf")
class(world)

#this looks like a dataframe, but note the "geometry" column.  this holds the shapes of each country
#we can plot them with ggplot!
ggplot() + 
  geom_sf(data = world) + 
  theme_void()

#you can mess around with the aesthetics
ggplot() + 
  geom_sf(data = world, fill = 'white') + 
  theme_void()

ggplot() + 
  geom_sf(data = world, fill = 'black') + 
  theme_void()

#now we can map our points:
ggplot() + 
  geom_sf(data = world, fill = 'white') + 
  geom_point(data = df, aes(x = Longitude, y = Latitude), color = 'steelblue', alpha = .25) + 
  theme_void()

#similarly, you can mess with the aesthetics
ggplot() + 
  geom_sf(data = world, fill = 'black') + 
  geom_point(data = df, aes(x = Longitude, y = Latitude), color = 'red', alpha = .25) + 
  theme_void() +
  theme(panel.background = element_rect(fill = "black"))


#what if we just want to plot the US?
#we could narrow down what coordinate bounds
ggplot() + 
  geom_sf(data = world, fill = 'white') + 
  coord_sf(ylim = c(min(df_usa$Latitude), max(df_usa$Latitude)), xlim = c(min(df_usa$Longitude), max(df_usa$Longitude))) +
  geom_point(data = df_usa, aes(x = Longitude, y = Latitude), color = 'steelblue', alpha = .25) + 
  theme_void()


#we might want to get more detail if we're just interested in the US
#to get state bounds, we can go to the census: https://www.census.gov/geographies/mapping-files/time-series/geo/carto-boundary-file.html
usa <- sf::read_sf('cb_2018_us_state_20m')

#this data format is called "shapefile" and it is commonly stored in a folder.  here we just tell R where the folder is located and it
#uses the files it needs to construct the SF object


ggplot() + 
  geom_sf(data = usa, fill = 'white') + 
  geom_point(data = df_usa, aes(x = Longitude, y = Latitude), color = 'steelblue', alpha = .25) + 
  theme_void()

#we probably want to drop the OCONUS stuff from the geospatial data and the starbucks data
#how do we know the FIPS codes? https://www.nrcs.usda.gov/wps/portal/nrcs/detail/?cid=nrcs143_013696
usa <- usa %>%
  filter(STATEFP <= 56 & STATEFP != '02' & STATEFP != '15')

df_conus <- df_usa %>%
  filter(!`State/Province` %in% c('AK','HI'))

ggplot() + 
  geom_sf(data = usa, fill = 'white') + 
  geom_point(data = df_conus, aes(x = Longitude, y = Latitude), color = 'steelblue', alpha = .25) + 
  theme_void()

#let's keep narrowing down - now to NY state
df_ny <- df_conus %>%
  filter(`State/Province` == 'NY')

ny <- usa %>%
  filter(STATEFP == 36)

ggplot() + 
  geom_sf(data = ny, fill = 'white') + 
  geom_point(data = df_ny, aes(x = Longitude, y = Latitude), color = 'steelblue', alpha = .25) + 
  theme_void()

#that's OK, but we probably want the county-level census data now:
#this is the whole country with county lines
usa_counties <- sf::read_sf('cb_2018_us_county_20m/')

ggplot() + 
  geom_sf(data = usa_counties, fill = 'white') + 
  theme_void()

#subsetting to NYS
ny <- usa_counties %>%
  filter(STATEFP == 36)

ggplot() + 
  geom_sf(data = ny, fill = 'white') + 
  geom_point(data = df_ny, aes(x = Longitude, y = Latitude), color = 'steelblue', alpha = .35) + 
  theme_void()


#points are useful, but sometimes it is useful to plot what is called a "choropleth" map that colors an entire area based on some attribute
#let's use county population: https://www.census.gov/data/datasets/time-series/demo/popest/2010s-counties-total.html#par_textimage_70769902
df_pop <- read_csv('co-est2019-alldata.csv')

#we only care about the census population in 2010, let's just do NY
ny_pop <- df_pop %>%
  filter(STATE == 36) %>%
  select(COUNTY, CENSUS2010POP)

#joining our population data to the geospatial data (note the order for the join)
ny_census_pop <- ny %>%
  left_join(ny_pop, by = c('COUNTYFP' = 'COUNTY'))

#might be more interesting with a log-scaled fill
ggplot() + 
  geom_sf(data = ny_census_pop, aes(fill = CENSUS2010POP)) + 
  theme_void() +
  scale_fill_continuous(name = "count", trans = scales::pseudo_log_trans(base = 10))

#or some different colors
ggplot() + 
  geom_sf(data = ny_census_pop, aes(fill = CENSUS2010POP)) + 
  theme_void() +
  scale_fill_viridis_c(name = "count", trans = scales::pseudo_log_trans(base = 10))

ggplot() + 
  geom_sf(data = ny_census_pop, aes(fill = CENSUS2010POP)) + 
  theme_void() +
  scale_fill_viridis_c(option = 'B', name = "count", trans = scales::pseudo_log_trans(base = 10))

#---Exercise---#
#1. webscrape the average annual temperatures from wikipedia: https://en.wikipedia.org/wiki/List_of_countries_by_average_yearly_temperature
#2. drop any records that don't come in as numeric
#3. join the temp data with the 'world' data we read in earlier 
#4. create choropleth maps for africa and south america using temperature as your feature
#5. bonus: change your scale so that hotter countries are dark read and cooler countries are light red

library(rvest)

page <- read_html('https://en.wikipedia.org/wiki/List_of_countries_by_average_yearly_temperature')
df_temp <- page %>%
  html_node('table') %>%
  html_table() %>%
  rename('country' = 'Country', 'temp' = 'Average yearly temperature (1961–1990 Celsius)') %>%
  mutate(temp = as.numeric(temp)) %>%
  filter(!is.na(temp))

africa <- world %>%
  filter(continent == 'Africa') %>%
  left_join(df_temp, by = c('admin' = 'country'))

ggplot() + 
  geom_sf(data = africa, aes(fill = temp)) + 
  theme_void() +
  scale_fill_gradient(low = '#fee8c8', high = '#7f0000')

south_america <- world %>%
  filter(continent == 'South America') %>%
  left_join(df_temp, by = c('admin' = 'country'))

ggplot() + 
  geom_sf(data = south_america, aes(fill = temp)) + 
  theme_void() +
  scale_fill_gradient(low = '#fee8c8', high = '#7f0000')



