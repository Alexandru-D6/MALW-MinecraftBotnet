#!/bin/sh
# called by Dockerfile

# go to directory where wsgi.py is
cd /home/flask_app/BotnetAPI
# start gunicorn
exec gunicorn -w 3 wsgi:app