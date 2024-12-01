from flask import Flask, jsonify, send_from_directory
import json
from flask_cors import CORS  # Import CORS

app = Flask(__name__)

CORS(app, origins="http://localhost:5173")

@app.route('/api/trains', methods=['GET'])
def get_trains():
    # Load the JSON file
    with open('train_img_data.json', 'r') as file:
        trains_data = json.load(file)
    return jsonify(trains_data)


@app.route('/plots/<path:filename>', methods=['GET'])
def serve_plots(filename):
    print("here!!")
    return send_from_directory('plots', filename)

if __name__ == '__main__':
    app.run(debug=True)