# --------------------------
# Author: Cillian Tighe
# CCY4: Research Project
# Supervisor: Cyril Connolly
# --------------------------

##### ----- APPLICATION SERVER ----- #####
shinyServer(function(input, output, session) {
  ##### ----- LOADING SHAPE FILES ----- #####
  region_shapefiles <- read_sf(dsn = "shape_files/region")
  ed_shapefiles <- read_sf(dsn = "shape_files/ed")
  sa_shapefiles <- read_sf(dsn = "shape_files/small_area")
  rs_shapefiles <- read_sf(dsn = "shape_files/rough_sleep")
  
  # These are reactive values that will be used to change the UI dynamically
  userInput <-
    reactiveValues(
      validCredentials = FALSE,
      authenticated = FALSE,
      username = "",
      statusLogin = NULL,
      statusReg = NULL
    )
  
  ##### ----- CODE FOR CREATING SHAPE FILES ----- #####
  #roughSleepShape = roughSleepers %>%
  #  st_as_sf(coords = c("longitude", "latitude"))
  #st_write(roughSleepShape, "ROUGH_SLEEPERS.shp")
  
  ##### ----- CONNECTING TO THE DATABASE ----- #####
  mySqlConnect <-
    dbConnect(
      drv = RMariaDB::MariaDB(),
      username = 'root',
      password = '',
      dbname = 'project',
      host = 'localhost'
    )
  
  ##### ----- FETCHING DATA FROM DATABASE ----- #####
  # Fetching region data
  result <- dbSendQuery(mySqlConnect, 'select * from region')
  homelessByRegion <- dbFetch(result)
  dbClearResult(result)
  
  # Fetching ed data
  result <- dbSendQuery(mySqlConnect, 'select * from electoral_div')
  homelessByED <- dbFetch(result)
  dbClearResult(result)
  
  # Fetching region detailed data
  result <-
    dbSendQuery(mySqlConnect, 'select * from region_detailed')
  region_detailed <- dbFetch(result)
  dbClearResult(result)
  
  # Fetching rs data
  result <-
    dbSendQuery(mySqlConnect, 'select * from rough_sleepers')
  roughSleepers <- dbFetch(result)
  dbClearResult(result)
  
  # Fetching rent prices data
  result <- dbSendQuery(mySqlConnect, 'select * from rent_prices')
  rentPrices <- dbFetch(result)
  dbClearResult(result)
  
  # Fetching agencies data
  result <- dbSendQuery(mySqlConnect, 'select * from agencies')
  agencies <- dbFetch(result)
  dbClearResult(result)
  
  # Fetching rent index data
  result <- dbSendQuery(mySqlConnect, 'select * from rent_index')
  rentIndex <- dbFetch(result)
  dbClearResult(result)
  
  #dbDisconnect(mySqlConnect)
  
  ##### ----- MAP MARKER FUNCTION ----- #####
  # The following pieces of functionality handle the user's input on the map
  # Creating a reactive value that will store the click position
  #data_of_click <- reactiveValues(clickedPolygon = NULL)
  
  # Storing the current clicked position data
  #observeEvent(input$mapView_shape_click, {
  #  data_of_click$clickedShape <- input$mapView_shape_click
  #})
  
  
  ##### ----- LOGIN EVENT HANDLER ----- #####
  observeEvent(input$loginSubmit, {
    # When the button is pressed, it will return a value greater than 1
    if (input$loginSubmit != 0) {
      # Querying the database
      result <-
        dbSendQuery(mySqlConnect, "select * from users where 1")
      credentials <- dbFetch(result)
      
      # Checking whether the username and password check out
      usernameValid <-
        which(credentials$username == input$loginUser)
      passwordValid <-
        which(credentials$password == digest(input$loginPass))
      
      # Checking if the inputed values are same as one is database, it true log the user in
      if (length(usernameValid) == 1 &&
          length(passwordValid) >= 1 &&
          (usernameValid %in% passwordValid)) {
        userInput$validCredentials <- TRUE
        userInput$username <- credentials$username
        dbClearResult(result)
      }
      
      # User is authenticated
      if (userInput$validCredentials == TRUE) {
        userInput$authenticated <- TRUE
        
      }
      
      # User is not authenticated (not logged in)
      else{
        userInput$authenticated <- FALSE
      }
      
      # If the the user details were not authenticated, throw back the errors
      if (userInput$authenticated == FALSE) {
        if (length(usernameValid) > 1) {
          userInput$statusLog <- "* Credentials Error"
        } else if (input$loginUser == "" ||
                   length(usernameValid) == 0) {
          userInput$statusLog <- "* Username Error"
        } else if (input$loginPass == "" ||
                   length(passwordValid) == 0) {
          userInput$statusLog <- "* Password Error"
        }
      }
      dbClearResult(result)
    }
    
  })
  
  
  ##### ----- REGISTER EVENT HANDLER ----- #####
  observeEvent(input$regSubmit, {
    # When the button is pressed, it will return a value greater than 1
    if (input$regSubmit != 0) {
      resultReg <-
        dbSendQuery(mySqlConnect, "select username from users where 1")
      nameCheck <- dbFetch(resultReg)
      
      # Checking if the username has been taken
      unameExist <- which(nameCheck$username == input$regUser)
      
      # Validating all the inputed data
      if (input$regUser == "") {
        userInput$statusReg <- "Please enter username"
      } else if (length(unameExist) >= 1) {
        userInput$statusReg <- "Username taken"
      } else if (input$regPass == "") {
        userInput$statusReg <- "Please enter password"
      } else if (input$regPass2 == "") {
        userInput$statusReg <- "Please enter password again"
      } else if (input$regPass != input$regPass2) {
        userInput$statusReg <- "Passwords do not match!"
      } else{
        # Clear errors
        userInput$statusReg <- ""
        
        # Readying data to be inputed to the database
        usrn <- input$regUser
        pass <- digest(input$regPass)
        
        # Querying the database
        result <-
          dbSendQuery(
            mySqlConnect,
            sprintf(
              "insert into users (username, password) values ('%s', '%s')",
              usrn,
              pass
            )
          )
        
        # Clearing the query and logging the user in
        dbClearResult(resultReg)
        userInput$authenticated <- TRUE
        userInput$username <- usrn
      }
      
    }
  })
  
  ##### ----- LOGIN PAGE RENDER ----- #####
  output$accountView <- renderUI({
    # If the user is not logged in, show the login page
    if (userInput$authenticated == FALSE) {
      material_row(
        ##### ----- LOGIN FORM ----- #####
        material_column(
          width = 4,
          offset = 1,
          material_card(
            depth = 5,
            title = "User Login",
            divider = TRUE,
            tags$br(),
            uiOutput("errorLogin"),
            material_row(
              material_column(
                width = 10,
                offset = 1,
                material_text_box(input_id = "loginUser",
                                  label = "Username")
              )
            ),
            material_row(
              material_column(
                width = 10,
                offset = 1,
                material_password_box(input_id = "loginPass",
                                      label = "Password")
              )
            ),
            material_row(material_column(
              width = 10,
              offset = 1,
              material_button(input_id = "loginSubmit",
                              label = "Submit")
            ))
          )
        ),
        
        ##### ----- REGISTER FORM ----- #####
        material_column(
          width = 4,
          offset = 2,
          material_card(
            depth = 5,
            title = "User Registration",
            divider = TRUE,
            tags$br(),
            uiOutput("errorReg"),
            material_row(
              material_column(
                width = 10,
                offset = 1,
                material_text_box(input_id = "regUser",
                                  label = "Username")
              )
            ),
            material_row(
              material_column(
                width = 10,
                offset = 1,
                material_password_box(input_id = "regPass",
                                      label = "Password")
              )
            ),
            material_row(
              material_column(
                width = 10,
                offset = 1,
                material_password_box(input_id = "regPass2",
                                      label = "Confirm Password")
              )
            ),
            material_row(material_column(
              width = 10,
              offset = 1,
              material_button(input_id = "regSubmit",
                              label = "Register")
            ))
          )
        )
      )
    }
    
    ##### ----- USER LOGGED IN ----- #####
    else{
      material_row(
        ##### ----- UPLOAD DATA ----- #####
        material_column(
          width = 4,
          offset = 1,
          material_card(
            depth = 5,
            title = "Upload New Data",
            divider = TRUE,
            fileInput(
              "fileUpload",
              "Choose CSV File",
              multiple = TRUE,
              accept = c(
                "text/csv",
                "text/comma-separated-values,text/plain",
                ".csv"
              )
            ),
            # Logout button
            material_floating_button(
              input_id = "accLogout",
              color = "teal",
              icon = "logout"
            )
          )
        ),
        ##### ----- DISPLAY UPLOADED DATA ----- #####
        material_column(
          width = 6,
          material_card(
            depth = 5,
            title = "View Data",
            divider = TRUE,
            tableOutput("tableDisplay")
          )
        )
      )
    }
  })
  
  ##### ----- FUNCTION FOR DISPLAYING DATA ----- #####
  output$tableDisplay <- renderTable({
    req(input$fileUpload)
    
    df <-
      read.csv(
        file = input$fileUpload$datapath,
        header = TRUE,
        sep = ","
      )
    
  })
  
  ##### ----- LOGOUT HANDLER ----- #####
  observeEvent(input$accLogout, {
    if (input$accLogout != 0) {
      userInput$validCredentials <- FALSE
      userInput$authenticated <- FALSE
      userInput$username <- ""
      userInput$statusLogin <- NULL
      userInput$statusReg <- NULL
    }
  })
  
  ##### ----- LOGIN ERROR OUTPUT ----- #####
  output$errorLogin <- renderUI({
    material_row(material_column(
      width = 10,
      offset = 1,
      tags$p(class = "error", userInput$statusLog)
    ))
  })
  
  ##### -----  REGISTER ERROR OUTPUT ----- #####
  output$errorReg <- renderUI({
    material_row(material_column(
      width = 10,
      offset = 1,
      tags$p(class = "error", userInput$statusReg)
    ))
  })
  
  ##### -----  NAME DISPLAY OUTPUT ----- #####
  output$displayName <- renderUI({
    if (userInput$username == "") {
      tags$h4("Account Login / Registration")
    }
    else{
      tags$h4("Welcome back, ", userInput$username)
    }
  })
  
  ##### ----- MODAL VIEW FUNCTION ----- #####
  output$modalPlot = renderPlotly({
    #region = data_of_click$clickedShape$id
    if (is.null(input$viewOptions) || input$viewList != "homeReg") {
      
    }
    
    # Changing the graph to be displayed depending on the user input
    else if (input$viewOptions == "All") {
      plot_ly(
        region_detailed,
        x = ~ age,
        y = ~ year,
        color = ~ region
      ) %>%
        add_lines()
    } else if (input$viewOptions == "Border") {
      plot_ly(
        data = region_detailed,
        x = ~ age,
        y = ~ year,
        color = ~ region,
        colors = "Set1"
      )
    } else if (input$viewOptions == "West") {
      plot_ly(
        region_detailed,
        y = ~ year,
        color = ~ region,
        type = "box"
      )
    } else if (input$viewOptions == "South West") {
      plot_ly(
        data = region_detailed,
        x = ~ age,
        y = ~ year,
        color = ~ region,
        colors = "Set1"
      )
    } else if (input$viewOptions == "Mid West") {
      plot_ly(
        region_detailed,
        x = ~ age,
        y = ~ year,
        color = ~ region
      ) %>%
        add_lines()
    } else if (input$viewOptions == "South East") {
      plot_ly(
        region_detailed,
        y = ~ year,
        color = ~ region,
        type = "box"
      )
    } else if (input$viewOptions == "Dublin") {
      plot_ly(
        data = region_detailed,
        x = ~ age,
        y = ~ year,
        color = ~ region,
        colors = "Set1"
      )
    } else if (input$viewOptions == "Mid East") {
      plot_ly(
        region_detailed,
        y = ~ year,
        color = ~ region,
        type = "box"
      )
    } else if (input$viewOptions == "Midlands") {
      plot_ly(
        region_detailed,
        x = ~ age,
        y = ~ year,
        color = ~ region
      ) %>%
        add_lines()
    }
  })
  
  ##### ----- OPTION LIST CHANGE ----- #####
  observeEvent(input$viewList, {
    ##### ----- NO VIEW LIST ----- #####
    if (input$viewList == "noView") {
      removeUI(selector = "#viewOptions")
    }
    
    ##### ----- REGIONAL LIST ----- #####
    else if (input$viewList == "homeReg") {
      removeUI(selector = "#viewOptions")
      insertUI(
        selector = "#controlsCard",
        where = "beforeEnd",
        ui =  material_radio_button(
          input_id = "viewOptions",
          label = "View Regions",
          choices = c(
            "All",
            "Border",
            "West",
            "South West",
            "Mid West",
            "South East",
            "Dublin",
            "Mid East",
            "Midlands"
          )
        )
      )
    }
    
    ##### ----- ED LIST ----- #####
    else if (input$viewList == "homeEd") {
      removeUI(selector = "#viewOptions")
    }
    
    ##### ----- ROUGH SLEEPRS LIST ----- #####
    else if (input$viewList == "roughSleep") {
      removeUI(selector = "#viewOptions")
      insertUI(
        selector = "#controlsCard",
        where = "beforeEnd",
        ui =  material_radio_button(
          input_id = "viewOptions",
          label = "View Rough Sleepers",
          choices = c(
            "Dublin",
            "Cork",
            "Limerick",
            "Galway",
            "Waterford",
            "Tralee",
            "Kilkenny",
            "Sligo",
            "Killarney",
            "Shannon",
            "Monaghan",
            "Roscommon",
            "Donegal",
            "Carlow",
            "Mullingar"
          )
        )
      )
    }
    
    ##### ----- HOMELESS AGENCIES LIST ----- #####
    else if (input$viewList == "homeAgency") {
      removeUI(selector = "#viewOptions")
      insertUI(
        selector = "#controlsCard",
        where = "beforeEnd",
        ui =  material_radio_button(
          input_id = "viewOptions",
          label = "View Homeless Agencies",
          choices = c(
            "All",
            "Focus Ireland",
            "Simon Community",
            "Inner City Helping Homeless"
          )
        )
      )
    }
    
    ##### ----- RENT PRICING LIST ----- #####
    else if (input$viewList == "rentPrice") {
      removeUI(selector = "#viewOptions")
      insertUI(
        selector = "#controlsCard",
        where = "beforeEnd",
        ui =  material_radio_button(
          input_id = "viewOptions",
          label = "View Locations",
          choices = c(
            "All",
            "Dublin",
            "Cork",
            "Limerick",
            "Galway",
            "Waterford",
            "Tralee",
            "Kilkenny",
            "Sligo",
            "Killarney",
            "Shannon",
            "Monaghan",
            "Roscommon",
            "Donegal",
            "Carlow",
            "Mullingar"
          )
        )
      )
    }
  })
  
  ##### ----- RENT PLOT ----- #####
  output$rentPlot = renderPlotly({
    #--- Show the spinner ---#
    material_spinner_show(session, "rentPlot")
    
    #--- Simulate calculation step ---#
    Sys.sleep(time = 1)
    
    #--- Hide the spinner ---#
    material_spinner_hide(session, "rentPlot")
    
    plot_ly(
      rentIndex,
      x = ~ city,
      y = ~ rent,
      frame = ~ year,
      type = "bar",
      color = ~ city
    )
  })
  
  ##### ----- HOMELESS PLOT ----- #####
  output$homelessPlot = renderPlotly({
    #--- Show the spinner ---#
    material_spinner_show(session, "homelessPlot")
    
    #--- Simulate calculation step ---#
    Sys.sleep(time = 1)
    
    #--- Hide the spinner ---#
    material_spinner_hide(session, "homelessPlot")
    
    plot_ly(homelessByED,
            y = ~ total,
            x = ~ ed,
            type = "box")
  })
  
  ##### ----- AGENCY MAP (SIMON) ----- #####
  output$simonMap <- renderLeaflet({
    leaflet(options = leafletOptions(zoomControl = FALSE)) %>%
      setView(lng = -6.27766,
              lat = 53.3503,
              zoom = 90) %>%
      addTiles()
  })
  
  ##### ----- AGENCY MAP (FOCUS) ----- #####
  output$focusMap <- renderLeaflet({
    leaflet(options = leafletOptions(zoomControl = FALSE)) %>%
      setView(lng = -6.2732,
              lat = 53.3435,
              zoom = 90) %>%
      addTiles()
  })
  
  ##### ----- AGENCY MAP (ICHH) ----- #####
  output$ichhMap <- renderLeaflet({
    leaflet(options = leafletOptions(zoomControl = FALSE)) %>%
      setView(lng = -6.24781,
              lat = 53.3543,
              zoom = 90) %>%
      addTiles()
  })
  
  ##### ----- MAP RENDER VIEW FUNCTION ----- #####
  output$mapView <- renderLeaflet({
    #--- Show the spinner ---#
    material_spinner_show(session, "mapView")
    
    #--- Simulate calculation step ---#
    Sys.sleep(time = 1)
    
    #--- Hide the spinner ---#
    material_spinner_hide(session, "mapView")
    
    ##### ----- MAP SEARCH VIEW ----- #####
    # If the input box for searching is empty, set the default view to the coordinates below
    if (input$searchMap == "") {
      ZOOM = 7
      LAT = 53.350140
      LONG = -6.266155
    }
    # Else find the location usind the geocode functionality from the ggmap library
    else{
      target_pos = geocode(input$searchMap)
      LAT = target_pos$lat
      LONG = target_pos$lon
      ZOOM = 12
    }
    
    ##### ----- MAP VIEW LIST (NO VIEW) ----- #####
    if (input$viewList == "noView") {
      leaflet(options = leafletOptions(zoomControl = FALSE)) %>%
        setView(lng = LONG,
                lat = LAT,
                zoom = ZOOM) %>%
        addTiles()
    }
    
    
    ##### ----- MAP VIEW LIST (HOME REG) ----- #####
    else if (input$viewList == "homeReg") {
      # Setting the color palette for the map
      qpal <- colorFactor("BuGn", homelessByRegion$region)
      
      # Joining the regional shape files to the homeless data on the common variable that is the GUID
      shapeFileJoin <-
        left_join(region_shapefiles,
                  homelessByRegion,
                  by = c("GUID" = "guid"))
      
      if (input$viewOptions == "All" ||
          is.null(input$viewOptions)) {
        regionMap <- shapeFileJoin
      }
      else{
        #Linking the input selection from the ui to the variable in the joined data
        regionMap = shapeFileJoin[shapeFileJoin$region == input$viewOptions, ]
      }
      
      # Rendering the data with leaflet
      regionMap %>%
        # Hiding the zoom options that are visible by default
        leaflet(options = leafletOptions(zoomControl = FALSE)) %>%
        setView(lng = LONG,
                lat = LAT,
                zoom = ZOOM) %>%
        addTiles() %>%
        addPolygons(
          layerId = ~ region,
          stroke = 1,
          smoothFactor = 0.2,
          fillOpacity = 0.5,
          color = ~ qpal(region),
          label = ~ paste("Homeless - 2018 Q4: ", total)
        )
    }
    
    ##### ----- MAP VIEW LIST (HOME ED) ----- #####
    else if (input$viewList == "homeEd") {
      # Setting the color palette for the map
      qpal <- colorNumeric("BuGn", homelessByED$total)
      
      # Joining the regional shape files to the homeless data on the common variable that is the GUID
      shapeFileJoin <-
        left_join(ed_shapefiles, homelessByED, by = c("GUID_" = "guid"))
      
      #Linking the input selection from the ui to the variable in the joined data
      #shapeFileJoinNew = shapeFileJoin[shapeFileJoin$region == input$region, ]
      
      # Rendering the data with leaflet
      shapeFileJoin %>%
        # Hiding the zoom options that are visible by default
        leaflet(options = leafletOptions(zoomControl = FALSE)) %>%
        setView(lng = LONG,
                lat = LAT,
                zoom = ZOOM) %>%
        addTiles() %>%
        addPolygons(
          layerId = ~ ed,
          stroke = 0,
          smoothFactor = 0.2,
          fillOpacity = 0.5,
          color = ~ qpal(total),
          label = ~ paste("Homeless - 2018 Q4: ", total)
        )
    }
    
    ##### ----- MAP VIEW LIST (ROUGH SLEEPERS) ----- #####
    else if (input$viewList == "roughSleep") {
      ed_shapefiles <- st_set_crs(ed_shapefiles, 4326)
      rs_shapefiles <- st_set_crs(rs_shapefiles, 4326)
      
      # Setting color palette
      qpal <- colorNumeric("BuGn", rs_shapefiles$total)
      
      shapeFileJoin <- st_join(ed_shapefiles, rs_shapefiles)
      
      #Linking the input selection from the ui to the variable in the joined data
      roughSleepMap = shapeFileJoin[shapeFileJoin$city == input$viewOptions, ]
      
      
      # Rendering the data with leaflet
      roughSleepMap %>%
        # Hiding the zoom options that are visible by default
        leaflet(options = leafletOptions(zoomControl = FALSE)) %>%
        addTiles() %>%
        addPolygons(
          layerId = ~ total,
          stroke = 1,
          smoothFactor = 0.2,
          fillOpacity = 0.5,
          color = ~ qpal(total),
          label = ~ paste("Rough Sleepers - 2018 Q4: ", total)
        )
    }
    
    ##### ----- MAP VIEW LIST (RENT PRICING) ----- #####
    else if (input$viewList == "rentPrice") {
      # Setting the color palette for the map
      qpal <- colorNumeric("BuGn", rentPrices$price)
      
      if (input$viewOptions == "All" ||
          is.null(input$viewOptions)) {
        rentMap <- rentPrices
      }
      else{
        #Linking the input selection from the ui to the variable in the joined data
        rentMap = rentPrices[rentPrices$city == input$viewOptions, ]
      }
      
      # Rendering the data with leaflet
      rentMap %>%
        # Hiding the zoom options that are visible by default
        leaflet(options = leafletOptions(zoomControl = FALSE)) %>%
        setView(lng = LONG,
                lat = LAT,
                zoom = ZOOM) %>%
        addTiles() %>%
        addCircleMarkers(
          radius = ~ price / 10,
          lat = ~ latitude,
          lng = ~ longitude,
          color = ~ qpal(price),
          stroke = 0.5,
          fillOpacity = 1,
          label = ~ paste("Average Rent - 2018 Q4: ", price)
        )
    }
    
    ##### ----- MAP VIEW LIST (AGENCIES) ----- #####
    else if (input$viewList == "homeAgency") {
      if (input$viewOptions == "All" || is.null(input$viewOptions)) {
        agenciesMap <- agencies
      }
      else{
        #Linking the input selection from the ui to the variable in the joined data
        agenciesMap = agencies[agencies$name == input$viewOptions, ]
      }
      
      # Rendering the data with leaflet
      agenciesMap %>%
        # Hiding the zoom options that are visible by default
        leaflet(options = leafletOptions(zoomControl = FALSE)) %>%
        setView(lng = LONG,
                lat = LAT,
                zoom = ZOOM) %>%
        addTiles() %>%
        addMarkers(
          lat = ~ latitude,
          lng = ~ longitude,
          label = ~ paste("Location: ", location)
        )
    }
  })
})
