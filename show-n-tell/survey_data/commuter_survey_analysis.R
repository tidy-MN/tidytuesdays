library(rio)
library(tidyverse)
library(DT)
library(plotly)
library(glue)
library(shiny)
library(shinyWidgets)

survey_data <- import("https://github.com/MPCA-data/tidytuesdays/raw/master/show-n-tell/survey_data/CommuterSurvey2020_nonames.xlsx")

#Check names of columns
names(survey_data)

#Remove irrelevant columns
survey_data <- select(survey_data, -(`Start time`:Name))

questions <- names(survey_data)

#Clean up second most important reason names
survey_data <- set_names(survey_data,
               ifelse(questions %>% str_detect("second most important reason"),
                      lag(questions) %>% str_replace("most important reason", "second most important reason"),
                      questions
                      )
               )

#Get number of very likely responses for each question
very_likely <- survey_data %>% summarize(
  across(
    where(
      ~any(
        str_detect(., "Likely|likely"), na.rm = T)
      ),
    ~sum(. %in% c("Very likely"), na.rm = T)
    )
  ) %>%
pivot_longer(everything(), names_to = "question", values_to = "very_likely")

#Get number of very likely responses or likely for each question
likely <- survey_data %>% summarize(
  across(
    where(
      ~any(
        str_detect(., "Likely|likely"), na.rm = T)
    ),
    ~sum(. %in% c("Very likely", "Likely"), na.rm = T)
  )
) %>%
  pivot_longer(everything(), names_to = "question", values_to = "at_least_likely")

popular <- full_join(very_likely, likely, by = "question")

popular_table <- datatable(popular, rownames = F,
          colnames = c("Question", "# Very likely", "# Likely or very likely"),
          filter = "top",
          options = list(pageLength = 100))

survey_long <- pivot_longer(survey_data, -ID, names_to = "question", values_to = "answer") %>%
  replace_na(list(answer = "No repsonse")) %>%
  mutate(answer = str_split(answer, ";")) %>%
  unnest(answer) %>%
  filter(answer != "")

survey_summary <- survey_long %>%
  group_by(question, answer) %>%
  summarize(count = n()) %>%
  group_by(question) %>%
  #If more than 10 possible options and less than 2 of same answer, put answer in "Other" category
  mutate(answer = ifelse(n() > 10 & count < 2 & answer != "No response", "Other", answer)) %>%
  group_by(question, answer) %>%
  summarize(count = sum(count)) %>%
  ungroup()

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      pickerInput("selected_question1", "Choose a question",
                  choices = unique(survey_summary$question),
                  options = pickerOptions(liveSearch = T)),
      width = 2
    ),
    
    mainPanel(
      plotlyOutput("responses1", height = "700px"),
      width = 10
    )
  )
)

server <- function(input, output, session) {
  
  v <- reactiveValues(
    q2 = NULL
  )
  
  output$responses1 <- renderPlotly(
    plot_ly(filter(survey_summary, question == input$selected_question1),
            x = ~reorder(answer, answer == "No repsonse"), y = ~count, source = "1") %>%
      add_bars(color = ~reorder(answer, answer == "No repsonse")) %>%
      layout(xaxis = list(title = ""),
             yaxis = list(title = "Count"),
             title = str_wrap(glue("Reponses to {input$selected_question1}<br>
                          Click a bar to see how people with that response answered another question"))
             )%>%
      event_register("plotly_click")
  )
  
  output$responses2 <- renderPlotly({
    req(event_data("plotly_click", source = "1"))
    clicked <- event_data("plotly_click", source = "1")
    respondents <- filter(survey_long,
                          question == input$selected_question1,
                          answer == clicked$x) %>%
      pull(ID)
    
    survey_summary2 <- filter(survey_long,
                               question == v$q2,
                               ID %in% respondents) %>%
      group_by(answer) %>%
      summarize(count = n()) %>%
      ungroup() %>%
      #If more than 10 possible options and less than 2 of same answer, put answer in "Other" category
      mutate(answer = ifelse(n() > 10 & count < 2 & answer != "No response", "Other", answer)) %>%
      group_by(answer) %>%
      summarize(count = sum(count)) %>%
      ungroup()
    
    plot_ly(survey_summary2,
            x = ~reorder(answer, answer == "No repsonse"), y = ~count) %>%
      add_bars(color = ~reorder(answer, answer == "No repsonse")) %>%
      layout(xaxis = list(title = ""),
             yaxis = list(title = "Count"),
             title = glue("Responses to {v$q2}
                          for people who answered {clicked$x} to {input$selected_question1}") %>%
               str_wrap())
  })
  
  observeEvent(event_data("plotly_click", source = "1"), {
    showModal(modalDialog(
      sidebarLayout(
        sidebarPanel(
          pickerInput("selected_question2", "Choose a question",
                      choices = unique(survey_summary$question),
                      selected = v$q2,
                      options = pickerOptions(liveSearch = T)),
          width = 2
        ),
        
        mainPanel(
          plotlyOutput("responses2", height = "600px"),
          width = 10
        )
      ),
      size = "l",
      footer = modalButton("Close"),
      easyClose = T
    ))
  })
  
  observeEvent(input$selected_question2, v$q2 <- input$selected_question2)
  
}

shinyApp(ui, server)

