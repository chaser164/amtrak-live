library(ggplot2)
library(dplyr)
library(lubridate)
library(grid)
library(tools)

# Function to create the geom_segment based on inputs
create_segment <- function(x_start, y_start, x_end, y_end, segment_end_time, stations) {
  # Convert categorical variables to numeric positions
  y_levels <- factor(stations, levels = stations)
  y_start <- which(y_levels == y_start)  # Find the numeric position of the starting station
  y_end <- which(y_levels == y_end)      # Find the numeric position of the ending station
  
  # If segment_end_time is NULL, show the full segment
  if (is.null(segment_end_time)) {
    return(data.frame(x_start = x_start, y_start = y_start, x_new = x_end, y_new = y_end))
  }
  
  # Calculate the time difference between start and end times
  time_diff <- as.numeric(difftime(x_end, x_start, units = "secs"))
  
  # If segment_end_time exceeds the end time, show the full segment
  if (segment_end_time >= x_end) {
    X <- 1
  } else if (segment_end_time <= x_start) {
    X <- 0
  } else {
    # Calculate the percentage completion based on segment_end_time
    X <- as.numeric(difftime(segment_end_time, x_start, units = "secs")) / time_diff
  }
  
  # Calculate the new y position based on the percentage X
  y_new <- y_start + X * (y_end - y_start)
  
  # Calculate the new x position based on the percentage X
  x_new <- x_start + X * (x_end - x_start)
  
  # Return the segment data
  return(data.frame(x_start = x_start, y_start = y_start, x_new = x_new, y_new = y_new))
}

abbreviations <- c("WAS", "NCR", "BWI", 
                   "BAL", "ABE", "NRK", 
                   "WIL", "PHL", "PHN", 
                   "TRE", "PJC", "NBK", 
                   "MET", "EWR", "NWK", 
                   "NYP", "NRO", "STM", 
                   "BRP", "NHV", "OSB", 
                   "NLC", "MYS", "WLY", 
                   "KIN", "PVD", "RTE", 
                   "BBY", "BOS")

get_included_stations <- function(csv_paths, abbreviations) {
  # Initialize a set to collect all mentioned stations
  mentioned_stations <- c()
  
  # Iterate through each CSV path
  for (csv_path in csv_paths) {
    
    station_data <- read.csv(csv_path, row.names = NULL)
    station_data <- station_data %>%
      filter(Scheduled.Arrival.Time != "" & Scheduled.Departure.Time != "")
    station_stops <- station_data$Abbreviation
    
    # Collect all mentioned stations (union of all stations in the CSVs)
    mentioned_stations <- union(mentioned_stations, station_stops)
  }
  
  # Filter the original abbreviations to include only the mentioned ones
  included_stations <- abbreviations[abbreviations %in% mentioned_stations]
  
  # Return the filtered abbreviations
  return(included_stations)
}


generate_train_schedule_plot <- function(csv_paths, bg=FALSE, main_plot=FALSE, show_scheduled=TRUE) {
  
  segment_end_time <- as.POSIXct(format(Sys.time(), tz = "America/New_York"), tz = "America/New_York")
  
  # if background, set to time in the past
  if (bg)
  {
    segment_end_time <- as.POSIXct("2021-11-11", format = "%Y-%m-%d", tz = "UTC")
  } 
  
  included_stations <- get_included_stations(csv_paths, abbreviations)
  
  # Initialize the plot and time range variables
  PLOT <- ggplot()
  global_min_time <- as.POSIXct(Inf, origin = "1970-01-01", tz = "America/New_York")
  global_max_time <- as.POSIXct(-Inf, origin = "1970-01-01", tz = "America/New_York")
  
  train_line_labels <- c()
  train_line_colors <- c()
  
  all_actual_segments <- list()    # To store actual time segments
  all_scheduled_segments <- list() # To store scheduled time segments
  
  for (csv_path in csv_paths) {
    # Extract label and color from the CSV file name
    file_name <- file_path_sans_ext(basename(csv_path))
    split_name <- strsplit(file_name, "_")[[1]]
    train_line_label <- split_name[1]  # Extract the label (e.g., "139")
    train_line_color <- split_name[2]  # Extract the color (e.g., "red")
    
    train_line_labels <- c(train_line_labels, train_line_label)
    train_line_colors <- c(train_line_colors, train_line_color)
    
    # Load train schedule data from CSV
    train_schedule <- read.csv(csv_path, row.names = NULL)
    
    # Filter out rows with missing times
    train_schedule <- train_schedule %>%
      filter(Scheduled.Arrival.Time != "" & Scheduled.Departure.Time != "")
    
    # Process train schedule data
    train_schedule <- train_schedule %>%
      mutate(
        Scheduled.Arrival.Time = as.POSIXct(Scheduled.Arrival.Time, format = "%Y-%m-%d %H:%M:%S", tz = "America/New_York"),
        Scheduled.Departure.Time = as.POSIXct(Scheduled.Departure.Time, format = "%Y-%m-%d %H:%M:%S", tz = "America/New_York"),
        Actual.Arrival.Time = as.POSIXct(Actual.Arrival.Time, format = "%Y-%m-%d %H:%M:%S", tz = "America/New_York"),
        Actual.Departure.Time = as.POSIXct(Actual.Departure.Time, format = "%Y-%m-%d %H:%M:%S", tz = "America/New_York"),
        Station_Order = factor(Abbreviation, levels = included_stations)
      )
    
    # Update global min and max times
    global_min_time <- min(global_min_time, min(train_schedule$Scheduled.Arrival.Time, na.rm = TRUE))
    global_min_time <- min(global_min_time, min(train_schedule$Actual.Arrival.Time, na.rm = TRUE))
    global_max_time <- max(global_max_time, max(train_schedule$Scheduled.Departure.Time, na.rm = TRUE))
    global_max_time <- max(global_max_time, max(train_schedule$Actual.Departure.Time, na.rm = TRUE))
    
    # Collect actual and scheduled segments
    for (i in 1:(nrow(train_schedule) - 1)) {
      # Horizontal and diagonal segments for actual times
      x_actual_start <- train_schedule$Actual.Arrival.Time[i]
      x_actual_end <- min(train_schedule$Actual.Departure.Time[i], segment_end_time)
      y_actual_position <- match(train_schedule$Abbreviation[i], included_stations)
      
      if (x_actual_start < x_actual_end) {
        all_actual_segments <- append(all_actual_segments, list(data.frame(
          x_start = x_actual_start, y_start = y_actual_position, x_new = x_actual_end, y_new = y_actual_position,
          train_line_label = train_line_label, color = train_line_color
        )))
      }
      
      # Diagonal segments for actual times
      x_actual_start <- train_schedule$Actual.Departure.Time[i]
      y_actual_start <- train_schedule$Abbreviation[i]
      x_actual_end <- train_schedule$Actual.Arrival.Time[i + 1]
      y_actual_end <- train_schedule$Abbreviation[i + 1]
      
      if (!is.na(x_actual_start) && !is.na(x_actual_end)) {
        diagonal_segment <- create_segment(x_actual_start, y_actual_start, x_actual_end, y_actual_end, segment_end_time, included_stations)
        diagonal_segment$train_line_label <- train_line_label
        diagonal_segment$color <- train_line_color
        all_actual_segments <- append(all_actual_segments, list(diagonal_segment))
      }
      
      # Horizontal and diagonal segments for scheduled times
      x_scheduled_start <- train_schedule$Scheduled.Arrival.Time[i]
      x_scheduled_end <- train_schedule$Scheduled.Departure.Time[i]
      y_scheduled_position <- match(train_schedule$Abbreviation[i], included_stations)
      
      if (x_scheduled_start < x_scheduled_end) {
        all_scheduled_segments <- append(all_scheduled_segments, list(data.frame(
          x_start = x_scheduled_start, y_start = y_scheduled_position, x_new = x_scheduled_end, y_new = y_scheduled_position,
          train_line_label = train_line_label, color = train_line_color
        )))
      }
      
      x_scheduled_start <- train_schedule$Scheduled.Departure.Time[i]
      y_scheduled_start <- train_schedule$Abbreviation[i]
      x_scheduled_end <- train_schedule$Scheduled.Arrival.Time[i + 1]
      y_scheduled_end <- train_schedule$Abbreviation[i + 1]
      
      if (!is.na(x_scheduled_start) && !is.na(x_scheduled_end)) {
        diagonal_segment <- create_segment(x_scheduled_start, y_scheduled_start, x_scheduled_end, y_scheduled_end, NULL, included_stations)
        diagonal_segment$train_line_label <- train_line_label
        diagonal_segment$color <- train_line_color
        all_scheduled_segments <- append(all_scheduled_segments, list(diagonal_segment))
      }
    }
  }
  
  # Combine all actual and scheduled segments into separate data frames
  actual_segments_df <- bind_rows(all_actual_segments)
  scheduled_segments_df <- bind_rows(all_scheduled_segments)
  
  # Add all segments to the plot
  if(show_scheduled) {
    PLOT <- PLOT + geom_segment(aes(x = x_start, y = y_start, xend = x_new, yend = y_new, color = "black"),
                 data = scheduled_segments_df, linewidth = 0.2, linetype = "dashed")
  } else {
    global_max_time <- segment_end_time
    
  }
  
  PLOT <- PLOT +
    geom_segment(aes(x = x_start, y = y_start, xend = x_new, yend = y_new, color = train_line_label),
                 data = actual_segments_df, linewidth = 0.4) +
    scale_x_datetime(
      limits = c(global_min_time, global_max_time),
      breaks = seq(from = floor_date(global_min_time, unit = "hour"),
                   to = ceiling_date(global_max_time, unit = "hour"),
                   by = "2 hour"),
      labels = scales::date_format("%H:%M", tz = "America/New_York")
    ) + # Add vertical black line
    scale_y_continuous(
      breaks = 1:length(included_stations),
      labels = included_stations
    ) +
    theme_minimal() +
    theme(
      legend.position = ifelse(length(csv_paths) > 1, "right", "none"),
      panel.grid.minor.y = element_blank(),
      axis.text.y = element_text(size = 8),
      plot.background = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "white", color = NA),
    ) +
  scale_color_manual(values = setNames(train_line_colors, train_line_labels)) +
    labs(x = "Time", y = "Station", title = ifelse(length(csv_paths) > 1, "Live Northeast Corridor Amtrak Marey-Style Plot", paste("Live Amtrak Marey-Style Plot for Train", train_line_label)), color = "Train Number")
  
  if(show_scheduled) {
    PLOT <- PLOT + geom_vline(xintercept = as.numeric(segment_end_time), linetype = "solid", color = "black", linewidth = 0.5)
  }
  
  plot_file <- train_line_label
  if (main_plot)
  {
    plot_file <- "main"
  }
  
  if (bg)
  {
    plot_file <- paste0(plot_file, "_bg")
  }

  
  ggsave(paste0("plots/", plot_file, "_plot.png"), plot = PLOT, width = 10, height = 6, dpi = 300)
  
  # return(PLOT)
}


# Get the list of CSV file paths in the directory
csv_files <- list.files("train_data", pattern = "\\.csv$", full.names = TRUE)

# main plot logic
generate_train_schedule_plot(csv_files, bg=FALSE, main_plot=TRUE)
generate_train_schedule_plot(csv_files, bg=TRUE, main_plot=TRUE)

# individual plots logic
for (csv_file in csv_files) {
  generate_train_schedule_plot(csv_file, bg=FALSE)
  generate_train_schedule_plot(csv_file, bg=TRUE)
}

