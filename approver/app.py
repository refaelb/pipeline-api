from urllib import response
import requests
from inspect import ArgSpec
from re import I
from sys import argv
from flask import Flask, request ,Response
import json
import yaml
# import git 
import os
from pathlib import Path
from flask import render_template


app = Flask(__name__)

@app.route('/pipeline_api/approve', methods=['POST'])
def approver():
    data = (request.data)
    print (data)
    approver_ui(data)
    return (data, "http://127.0.0.1:5000/pipeline_api/approve/ui/"+request_id)

request_id='21321'
@app.route('/pipeline_api/approve/ui/'+request_id, methods=['GET'])
def approver_ui(data):
    print (data)
    return render_template("home.html", variable="data")


@app.route('/pipeline_api/approve/status', methods=['POST'])
def status():
    status=request.form['status']
    print()
    # return status
    return requests.post('/pipeline_api/crud', data=status)


if __name__ == '__main__':
    app.run(debug=True)