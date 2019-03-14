# --------------------------
# Author: Cillian Tighe
# CCY4: Research Project
# Supervisor: Cyril Connolly
# --------------------------

##### ----- APPLICATION UI ----- #####
shinyUI(
  # Material page is the wrapper for the app which uses Material Design for the style and layout
  material_page(
    # Linking the style.css to the main application
    tags$title("Lámh Eile"),
    tags$link(rel = "stylesheet", type = "text/css", href = "css/style.css"),
    
    ##### ----- NAVIGATION BAR ----- #####
    # Setting the style and layout of the navigation bar
    title = "",
    nav_bar_fixed = TRUE,
    include_fonts = TRUE,
    include_icons = TRUE,
    nav_bar_color = "teal",
    
    ##### ----- SIDE NAVIGATION BAR ----- #####
    material_side_nav(
      image_source = "img/option_3.png",
      fixed = TRUE,
      
      ##### ----- MAIN MENU ----- #####
      material_row(class = "menuHead",
                   material_column(
                     width = 10,
                     offset = 1,
                     tags$h6("MENU")
                   )),
      tags$hr(),
      
      ##### ----- MENU DIRECTORY START ----- #####
      # Listing all the menu items with icons
      material_side_nav_tabs(
        side_nav_tabs = c(
          "Home" = "home",
          "View Map" = "map",
          "Projections" = "proj",
          "Homeless Agencies" = "agency",
          "Account" = "account"
        ),
        icons = c("home", "map", "insert_chart", "people", "lock")
      ),
      
      ##### ----- BREAKING CONTENT ON MENU ----- #####
      tags$br(),
      tags$br(),
      tags$br(),
      tags$br(),
      tags$br(),
      tags$br(),
      tags$br(),
      tags$br(),
      tags$br(),
      tags$br(),
      tags$br(),
      tags$br(),
      
      ##### ----- CONTACT INFORMATION ----- #####
      material_row(class = "menuHead",
                   material_column(
                     width = 10,
                     offset = 1,
                     tags$h6("ADDITIONAL LINKS")
                   )),
      tags$hr(),
      ##### ----- GitHub Link ----- #####
      material_row(material_column(
        width = 10,
        offset = 1,
        HTML(
          "<a href='https://github.com/cilliantighe' target='_blank'> GitHub Link <i class='icon material-icons'>open_in_new</i></a>"
        )
      )),
      
      ##### ----- LinkedIn ----- #####
      material_row(material_column(
        width = 10,
        offset = 1,
        HTML(
          "<a href='https://www.linkedin.com/in/cillian-tighe/' target='_blank'> LinkedIn <i class='icon material-icons'>open_in_new</i></a>"
        )
      )),
      
      ##### ----- Website ----- #####
      material_row(material_column(
        width = 10,
        offset = 1,
        HTML(
          "<a href='http://www.cillian-tighe.com' target='_blank'> Website <i class='icon material-icons'>open_in_new</i></a>"
        )
      ))
    ),
    ##### ----- MENU DIRECTORY END ----- #####
    
    ##### ----- MENU CONTENT START ----- #####
    ##### ----- HOME ----- #####
    material_side_nav_tab_content(
      side_nav_tab_id = "home",
      # Listing tabs on the home screen
      material_tabs(
        color = "teal",
        tabs = c(
          "Welcome" = "welcome_tab",
          "About" = "about_tab",
          "Contact" = "contact_tab"
        )
      ),
      # Defining the content in each tab
      material_tab_content(
        tab_id = "welcome_tab",
        material_row(material_column(
          width = 10,
          offset = 1,
          tags$h4("Lámh Eile"),
          tags$hr()
        )),
        material_row(material_column(
          width = 10,
          offset = 1,
          tags$p("Navigate through the web applicatin using the side navigation")
        ))
      ),
      material_tab_content(
        tab_id = "about_tab",
        material_row(material_column(
          width = 10,
          offset = 1,
          tags$h4("About the Application"),
          tags$hr()
        )),
        material_row(material_column(
          width = 10,
          offset = 1,
          tags$p("....")
        ))
      ),
      material_tab_content(
        tab_id = "contact_tab",
        material_row(material_column(
          width = 10,
          offset = 1,
          tags$h4("Contact Information"),
          tags$hr()
        )),
        material_row(material_column(
          width = 10,
          offset = 1,
          tags$p("...")
        ))
      )
    ),
    
    
    ##### ----- MAP VIEW ----- #####
    material_side_nav_tab_content(
      side_nav_tab_id = "map",
      # Map render with the leaflet package
      leafletOutput("mapView", width = "100%"),
      # Controls that allows the user to change the content to view on the map
      absolutePanel(
        top = 75,
        right = 25,
        width = 300,
        draggable = FALSE,
        # Using the material card to give the the controls a nice look
        material_card(
          id = "controlsCard",
          title = "Select a View",
          depth = 5,
          # Search box for location
          material_text_box(input_id = "searchMap", label = "Search Map"),
          
          # Listing the view options
          material_radio_button(
            input_id = "viewList",
            label = "View Data",
            choices = c(
              "No View (Default)" = "noView",
              "Homelessness by Region" = "homeReg",
              "Homelessness by ED" = "homeEd",
              "Rough Sleepers by Area" = "roughSleep",
              "Homeless Agencies" = "homeAgency",
              "Rent Prices" = "rentPrice"
            ),
            selected = "noView"
          ),
          material_row(material_column(width = 12)),
          material_modal(
            modal_id = "modalView",
            button_text = "View Details",
            button_icon = "open_in_browser",
            title = "Detailed Analysis",
            plotlyOutput("modalPlot", height = "300px", width = "1000px")
          ),
          material_row(material_column(width = 12))
        )
      )
    ),
    
    ##### ----- Projections VIEW ----- #####
    material_side_nav_tab_content(
      side_nav_tab_id = "proj",
      material_row(material_column(
        width = 10,
        offset = 1,
        tags$h4("Data Projections"),
        tags$hr()
      )),
      # Displaying plotly graph
      material_row(material_column(
        width = 10,
        offset = 1,
        material_card(
          title = "Rent Index 2001 - 2019",
          divider = TRUE,
          depth = 5,
          plotlyOutput("rentPlot", height = "250px")
        )
      )),
      # Displaying plotly graph
      material_row(material_column(
        width = 10,
        offset = 1,
        material_card(
          title = "Homelessness by Electoral Division",
          divider = TRUE,
          depth = 5,
          plotlyOutput("homelessPlot", height = "250px")
        )
      ))
    ),
    
    ##### ----- Agency VIEW ----- #####
    material_side_nav_tab_content(
      side_nav_tab_id = "agency",
      material_row(material_column(
        width = 10,
        offset = 1,
        tags$h4("Homeless Agencies"),
        tags$hr()
      )),
      material_row(
        material_column(
          width = 3,
          offset = 1,
          material_card(
            title = "Focus Ireland",
            divider = TRUE,
            depth = 5,
            tags$br(),
            leafletOutput("focusMap", width = "100%"),
            tags$br(),
            HTML(
              "<h6>Website: </h6><a href='https://www.focusireland.ie/' target='_blank'> FocusIreland.ie</a>"
            ),
            tags$br(),
            HTML("<h6>Contact:</h6><p class='info'>01 881 5900</p>")
          )
        ),
        material_column(
          width = 4,
          material_card(
            title = "Simon Community",
            divider = TRUE,
            depth = 5,
            tags$br(),
            leafletOutput("simonMap", width = "100%"),
            tags$br(),
            HTML(
              "<h6>Website: </h6><a href='https://www.dubsimon.ie/' target='_blank'> Simon.ie</a>"
            ),
            tags$br(),
            HTML("<h6>Contact:</h6><p class='info'>01 635 4800</p>")
          )
        ),
        material_column(
          width = 3,
          material_card(
            title = "Inner City Helping Homeless",
            divider = TRUE,
            depth = 5,
            tags$br(),
            leafletOutput("ichhMap", width = "100%"),
            tags$br(),
            HTML(
              "<h6>Website: </h6><a href='https://www.ichh.ie/' target='_blank'> ICHH.ie</a>"
            ),
            tags$br(),
            HTML("<h6>Contact:</h6><p class='info'>01 888 1804</p>")
          )
        )
      )
    ),
    
    ##### ----- Login VIEW ----- #####
    material_side_nav_tab_content(
      side_nav_tab_id = "account",
      material_row(material_column(
        width = 10,
        offset = 1,
        uiOutput("displayName"),
        tags$hr()
      )),
      uiOutput("accountView")
    )
  )
)
