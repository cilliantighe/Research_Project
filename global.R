# --------------------------
# Author: Cillian Tighe
# CCY4: Research Project
# Supervisor: Cyril Connolly
# --------------------------

# The global.R file runs once before your app starts.
# This is handy for listing any required libaries or data that needs to be loaded before the app starts.

##### ----- LOADING LIBRARIES ----- #####
# shiny is used the creating interactive web apps
library(shiny)
# shinymaterial is an extension to shiny with material design components
library(shinymaterial)
# Sf is used for handling shape files
library(sf)
# leaflet is used for rendering map views
library(leaflet)
# tidyverse is used to model and visualise data
library(tidyverse)
# ggmap is used for geolocating places, towns, cities etc.
library(ggmap)
# plotly is used for creating dynamic and interactive graphics
library(plotly)
# dbi and rmariadb are used for handling database requests and connections and hashing data
library(DBI)
library(RMariaDB)
library(digest)