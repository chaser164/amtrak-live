import requests
import csv
import json
from datetime import datetime
import sys

args = sys.argv

if len(args) < 2:
    print("invalid command line args")
    sys.exit()

img_id = args[1]

r_colors = [
    "red", "blue", "green", "cyan", "magenta", "orange", "purple",
    "brown", "black", "darkred", "darkblue", "darkgreen", "darkorange",
    "darkviolet", "darkgrey", "steelblue", "gold", "orchid", "turquoise",
    "chocolate", "tomato", "maroon", "navy", "coral",
    "firebrick", "seagreen", "mediumblue", "dodgerblue", "royalblue",
    "springgreen", "forestgreen", "goldenrod", "hotpink", "deeppink",
    "mediumvioletred", "midnightblue", "indigo", "violet", "slateblue",
    "chartreuse", "darkslategrey", "indianred"
]

allowed_stations = {
    "WAS", "NCR", "BWI", "BAL", "ABE", "NRK", 
    "WIL", "PHL", "PHN","CWH", "TRE", "PJC", "NBK", 
    "MET", "EWR", "NWK", "NYP", "NRO", "STM", 
    "BRP", "NHV", "OSB", "NLC", "MYS", "WLY", 
    "KIN", "PVD", "RTE", "BBY", "BOS"
}

url = "https://api-v3.amtraker.com/v3/trains"


def format_timestamp(input_timestamp):
    date_time = input_timestamp.split('T')
    time = date_time[1].split('-')[0].split('+')[0]
    return f"{date_time[0]} {time}"


def calculate_percentage(actual_arr_time, start_time, end_time):
    # Calculate the total time range (in minutes)
    total_duration = (end_time - start_time).total_seconds() / 60
    # Calculate the relative position of the actual arrival time within the entire range
    relative_position = (actual_arr_time - start_time).total_seconds() / 60
    # Calculate the percentage
    out = (100 - (relative_position / total_duration * 100))
    if out < 0 or out > 100:
        out = 93
    return out


try:
    # Send a GET request to fetch the JSON data
    response = requests.get(url)
    response.raise_for_status()  # Raise an HTTPError if the response was not successful
    
    # Parse the JSON data into a dictionary
    train_data = response.json()
    
    # Check the type of the outermost structure (should be a dictionary)
    if not isinstance(train_data, dict):
        print(f"Unexpected data structure: {type(train_data)}")
    
except requests.RequestException as e:
    print(f"Error fetching the data: {e}")

acelas = []
ners = []

for train_id in train_data:
    if train_data[train_id][0]['routeName'] == 'Acela':
        acelas.append(train_data[train_id][0])
    elif train_data[train_id][0]['routeName'] == 'Northeast Regional':
        ners.append(train_data[train_id][0])

color_idx = 0

active_trains = [{'id': 'All Trains', 
                  'foreground_img': f'plots/main_plot_{img_id}.png',
                  'background_img': f'plots/main_bg_plot_{img_id}.png',
                  'animation_start': 100},
                  {'id': 'Northbound', 
                  'foreground_img': f'plots/north_plot_{img_id}.png',
                  'background_img': f'plots/north_bg_plot_{img_id}.png',
                  'animation_start': 100},
                  {'id': 'Southbound', 
                  'foreground_img': f'plots/south_plot_{img_id}.png',
                  'background_img': f'plots/south_bg_plot_{img_id}.png',
                  'animation_start': 100}]

# Build Acela and Northeast Regional CSVs
for trains in [acelas, ners]:
    for train in trains:
        filename = f'train_data/{"north" if int(train["trainNum"]) % 2 == 0 else "south"}/{train["trainNum"]}_{r_colors[color_idx % len(r_colors)]}.csv'
        color_idx += 1
        schedule_data = []
        
        # Extract station data
        for station in train['stations']:
            if station['code'] not in allowed_stations:
                continue
            try:
                row = { 'Abbreviation': station['code'],
                        'Scheduled Arrival Time': format_timestamp(station['schArr']),
                        'Scheduled Departure Time': format_timestamp(station['schDep']),
                        'Actual Arrival Time': format_timestamp(station['arr']),
                        'Actual Departure Time':  format_timestamp(station['dep'])
                }
            except:
                continue
            schedule_data.append(row)

        if len(schedule_data) <= 2:
            continue
        
        # Write the CSV
        with open(filename, mode="w") as file:
            writer = csv.DictWriter(file, fieldnames=schedule_data[0].keys())
            writer.writeheader()
            writer.writerows(schedule_data)

        # Calculate the "animation_start" percentage based on first Actual Arrival Time
        actual_arr_time = datetime.strptime(schedule_data[0]['Actual Arrival Time'], "%Y-%m-%d %H:%M:%S")

        start_time_sched = datetime.strptime(schedule_data[0]['Scheduled Arrival Time'], "%Y-%m-%d %H:%M:%S")
        start_time = datetime.strptime(schedule_data[0]['Actual Arrival Time'], "%Y-%m-%d %H:%M:%S")
        start_time = min(start_time, start_time_sched)
        end_time_sched = datetime.strptime(schedule_data[-1]['Scheduled Departure Time'], "%Y-%m-%d %H:%M:%S")
        end_time = datetime.strptime(schedule_data[-1]['Actual Departure Time'], "%Y-%m-%d %H:%M:%S")
        end_time = max(end_time, end_time_sched)
        
        # Calculate the percentage position of the actual arrival time
        animation_start = calculate_percentage(actual_arr_time, start_time, end_time)

        # Add to active_trains with "animation_start"
        active_trains.append({'id': f'{train["trainNum"]}', 
                              'foreground_img': f'plots/{train["trainNum"]}_plot_{img_id}.png',
                              'background_img': f'plots/{train["trainNum"]}_bg_plot_{img_id}.png',
                              'animation_start': animation_start})

# Write the JSON list
with open("new_train_img_data.json", "w") as json_file:
    json.dump(active_trains, json_file, indent=4)
