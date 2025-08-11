#' ---
#' title: "AsterObs"
#' runtime: shiny
#' ---

#setup
library(leaflet)
library(tidyverse)
library(lubridate)
library(shiny)
library(bslib)
library(shinydashboard)
library(fontawesome)
library(bipartite)
library(bipartiteD3)
library(r2d3)

#plants
aster_raw = read_csv("https://raw.githubusercontent.com/kaionaa/Bee-Search/refs/heads/main/aster_obs.csv")
#aster_raw = read_csv("C:\\Users\\kaion\\OneDrive\\Desktop\\DATA 510\\data\\aster_obs.csv")
#bees
alloba = read_csv("https://raw.githubusercontent.com/kaionaa/Bee-Search/refs/heads/main/Melissodes_Lindh_OBA_Data_2-24-2023.xlsx%20-%20Sheet1.csv")
#alloba = read_csv("C:\\Users\\kaion\\OneDrive\\Desktop\\DATA 510\\data\\Melissodes_Lindh_OBA_Data_2-24-2023.xlsx - Sheet1 (1).csv")

aster = aster_raw%>%
  mutate(ob_date = as.Date(ob_date),
         year = year(ob_date),
         season = case_when(
           month(ob_date) %in% 3:5 ~ "Spring",
           month(ob_date) %in% 6:8 ~ "Summer",
           month(ob_date) %in% 9:11 ~ "Fall",
           TRUE ~ "Winter"
         ),
         native = as.logical(native))%>%
  filter(year>=2018)%>%
  drop_na()

# Filter data x2
cleanoba2 = alloba %>%
  mutate(`Collection Date` = as.Date(`Collection Date`),
         season = case_when(
           month(`Collection Date`) %in% 3:5 ~ "Spring",
           month(`Collection Date`) %in% 6:8 ~ "Summer",
           month(`Collection Date`) %in% 9:11 ~ "Fall",
           TRUE ~ "Winter"),
         `Dec. Long.` = as.numeric(`Dec. Long.`),
         `Dec. Lat.` = as.numeric(`Dec. Lat.`)) %>%
  filter(!is.na(`Dec. Long.`), !is.na(`Dec. Lat.`), Species != "vosnesenskii")

ui <- dashboardPage (skin = "purple",
                     dashboardHeader(title = "Collections"),
                     dashboardSidebar(
                       sidebarMenu(
                         menuItem("Welcome", tabName = "welc", icon = icon("face-smile")),
                         menuItem("Relationship", tabName = "rel", icon = icon("heart")),
                         menuItem("Aster Obs", tabName = "ast", icon = icon("tree")),
                         menuItem("Melissodes Obs", tabName = "mel", icon = icon("bug"))
                       )
                     ),
                     dashboardBody(
                       tabItems(
                         tabItem(tabName = "welc",
                                 fluidPage(
                                   titlePanel("Welcome to Collections")
                                 )),
                         tabItem(tabName = "rel",
                                 fillPage(
                                   titlePanel("Relationship between Bee Specimens and Host Flowers"),
                                   d3Output("sank")
                                   )),
                         tabItem(tabName = "ast",
                                 fluidPage(
                                   titlePanel("Map of Aster Flower Observations"),
                                   sidebarLayout(
                                      sidebarPanel(
                                      actionButton("deselectAllBtn1", "Deselect All"),
                                      checkboxGroupInput("season1",
                                                   "Season:",
                                                   choices = unique(aster$season),
                                                   selected = unique(aster$season)),
                                      actionButton("deselectAllBtn2", "Deselect All"),
                                      checkboxGroupInput("genus",
                                                          "Genus:",
                                                          choices = unique(aster$genus),
                                                          selected = unique(aster$genus))
                                       ),
                                      mainPanel(class = "main-panel-custom-height",
                                               leafletOutput("map"))
                                 )
                                )
                              ),
                         tabItem(tabName = "mel",
                                 fluidPage(
                                   titlePanel("Map of Melissodes Bee Collections"),
                                   sidebarLayout(
                                     sidebarPanel(
                                       actionButton("deselectAllBtn3", "Deselect All"),
                                       checkboxGroupInput("season2",
                                                          "Season:",
                                                          choices = unique(cleanoba2$season),
                                                          selected = unique(cleanoba2$season)),
                                       actionButton("deselectAllBtn4", "Deselect All"),
                                       checkboxGroupInput("species",
                                                          "Species:",
                                                          choices = unique(cleanoba2$Species),
                                                          selected = unique(cleanoba2$Species)),
                                     ),
                                     mainPanel(leafletOutput("map2"))
                                   )                                 
                             )
                       )
                 )
          )
    )
  
server <- function(input, output, session) {
    
  observeEvent(input$deselectAllBtn1, {
    updateCheckboxGroupInput(session, "season1", selected = character(0))
  })
  observeEvent(input$deselectAllBtn2, {
    updateCheckboxGroupInput(session, "genus", selected = character(0))
  })
  observeEvent(input$deselectAllBtn3, {
    updateCheckboxGroupInput(session, "season2", selected = character(0))
  })
  observeEvent(input$deselectAllBtn4, {
    updateCheckboxGroupInput(session, "species", selected = character(0))
  })
  
    # Filter df
    filter_df = reactive({
      req(input$season1, input$genus)
      df <- aster
      
      if (!is.null(input$season1) & length(input$season1) > 0) {
        df <- df %>% filter(season %in% input$season1)
      }
      
      if (!is.null(input$genus) & length(input$genus) > 0) {
        df <- df %>% filter(genus %in% input$genus)
      }
      
      df %>% distinct(ob_id, .keep_all = TRUE)
    })
    
    # Make map
    output$map <- renderLeaflet({
      df = filter_df()
      m <- leaflet() %>%
        addProviderTiles(providers$CartoDB.Positron) 
      
      if (nrow(df) > 0) {
        m <- m %>%
          addCircleMarkers(
            data = df,
            lng = ~lon,
            lat = ~lat,
            radius = 1,
            popup = ~paste(
              "<b>Species:</b>", scientific_name, "<br>",
              "<b>Date:</b>", ob_date, "<br>",
              "<b>Native:</b>", ifelse(is.na(native), "Unknown", ifelse(native, "Yes", "No"))
            )
          )
      }
      
      m
    })
    output$sank <- renderD3({
      ##SANKEY PLOT
      cleanoba = alloba%>%
        filter(!is.na(`Associated plant`))
      cleanoba$`Associated plant` <- sub(" .*", "", cleanoba$`Associated plant`)
      someoba = table(cleanoba$Species, cleanoba$`Associated plant`)
      cont_df = as.data.frame(someoba)
      cont_df = cont_df%>% drop_na()%>% filter(Freq>=1)
      intdf = data.frame(higher = cont_df$Var1,
                         lower = cont_df$Var2,
                         freq = cont_df$Freq)
      bipartite_D3(data=intdf, 
                   colouroption = "brewer", 
                   ColourBy = 1, 
                   PrimaryLab = 'Melissodes Species',
                   SecondaryLab = 'Aster Plants')
    })

    
    # Reactive df
    filter_df2 = reactive({
      req(input$season2, input$species)

      if (!is.null(input$season2) & length(input$season2) > 0) {
        cleanoba2 <- cleanoba2 %>% filter(season %in% input$season2)
      }
      
      if (!is.null(input$species) & length(input$species) > 0) {
        cleanoba2 <- cleanoba2 %>% filter(Species %in% input$species)
      }
      
      cleanoba2 %>% distinct(SpecimenID, .keep_all = TRUE)
    })
    
    # Make map2
    output$map2 <- renderLeaflet({
      df2 = filter_df2()
      
      m2 <- leaflet() %>%
        addProviderTiles(providers$CartoDB.Positron) 
      
      if (nrow(df2) > 0) {
        m2 <- m2 %>%
          addCircleMarkers(
            data = df2,
            lng = ~`Dec. Long.`,
            lat = ~`Dec. Lat.`,
            radius = 1,
            popup = ~paste(
              "<b>Species:</b>", Species, "<br>",
              "<b>Date:</b>", `Collection Date`, "<br>",
              "<b>Sex:</b>", sex, "<br>",
              "<b>Plant:</b>",`Plant genus-species`)
            )
      }
      
      m2
    })
}
  
# Run the application
shinyApp(ui = ui, server = server)


