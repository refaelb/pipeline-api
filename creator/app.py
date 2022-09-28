from tokenize import Token
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


valuse="""name: {}
replicaCount: {}

images:
  PullSecrets: {}
  repository: {}
  tag: {}

service:
 ports: {}

volume:
  - enable: {}
    name: {}
    type: volumeClaim
    claimName: {} 
    mounts:
      - mountPath: {}
        subPath: {}

config:
  configmaps: {}

ingress:
  enabled: {}
  annotations: 
    myannotation: test
  hosts:
  - host: {}
    paths:
      - path: {}
        service: {}
        port: 80
env:
  - name: {}
    value: {}
"""


@app.route('/pipeline_api/creator', methods=['POST'])
def creator():
    data=(request.data)
    json_data=json.loads(data)
    project_name = (json_data["project_name"])
    azure_user=(json_data["azure_user"])
    pullSecrets=(json_data["pullSecrets"])
    configmap=(json_data["configMap"])
    services=(json_data["services"])
    for service in services:
        print (service)
        print (json_data["services"][service]["name"])
        service_name=(json_data["services"][service]["name"])
        service_tag=(json_data["services"][service]["tag"])
        service_repo=(json_data["services"][service]["repository"])
        service_replica_count=(json_data["services"][service]["replicacount"])
        service_port=(json_data["services"][service]["port"])
        volume_status=(json_data["services"][service]["volumes"]["enable"])
        volume_name=(json_data["services"][service]["volumes"]["name"])
        volume_mount=(json_data["services"][service]["volumes"]["mount_path"])
        volume_sub=(json_data["services"][service]["volumes"]["sub_path"])
        ingress_status=(json_data["services"][service]["ingress"]["enable"])
        ingress_path=(json_data["services"][service]["ingress"]["path"])
        ingress_host=(json_data["services"][service]["ingress"]["host"])
        ingress_service_name=(json_data["services"][service]["ingress"]["service_name"])
        env_name=(json_data["services"][service]["env"]["name"])
        env_value=(json_data["services"][service]["env"]["value"])
        write(project_name, service_name,service_replica_count, pullSecrets, service_repo, service_tag,service_port,volume_status,volume_name, volume_mount, volume_sub,configmap,ingress_status,ingress_host,ingress_path,ingress_service_name,env_name, env_value)
    helmfile_write(project_name, azure_user)
    return  "200 OK"

##create values.yaml files
def write( project_name,service_name,service_replica_count, pullSecrets, service_repo, service_tag,service_port,volume_status,volume_name, volume_mount, volume_path,configmap,ingress_status,ingress_host,ingress_sub,ingress_service_name,env_name, env_value):
    if not os.path.exists("./../../projects/"+project_name+"/values"):
      os.makedirs("./../../projects/"+project_name+"/values")
    with open ("./../../projects/"+project_name+"/values/"+service_name+"-values.yaml","a+") as f :
        var_list = yaml.load(valuse .format(service_name,service_replica_count, pullSecrets, service_repo, service_tag,service_port,volume_status,volume_name,volume_name, volume_mount, volume_path,configmap,ingress_status,ingress_host,ingress_sub,ingress_service_name,env_name, env_value), Loader=yaml.BaseLoader)
        yaml.dump(var_list, f, sort_keys=False)


def helmfile_write(project_name, azure_user):
    os.system("cp -r ./helmfile ./../../projects/"+ project_name)
    maker(project_name, azure_user)
    git(project_name)
    create_pipeline(project_name)

##maker project api
def maker(project_name ,azure_user):
    ranchToken=os.environ(['RANCER_TOKEN'])
    username=os.environ(['USERNAME'])
    token=os.environ(['TOKEN'])
    os.system("chmod +x maker/new-api.sh")
    os.system("./maker/new-api.sh {} {} {} {} {} ".format(project_name ,azure_user,ranchToken, username, token))

##push values & helmfile to azure repo
def git(project_name):
    username=os.environ(['USERNAME'])
    token=os.environ(['TOKEN'])
    os.system("chmod +x git_command.sh ")
    os.system("./git_command.sh {} {} {}".format(project_name,token,username))

##create pipline to new project in azure devops
def create_pipeline(project_name):
    username=os.environ(['USERNAME'])
    token=os.environ(['TOKEN'])
    os.system("chmod +x create_pipeline.sh ")
    os.system (" create_pipeline.sh {} {} {}".format(project_name,username,token))


            

if __name__ == '__main__':
    app.run( host='0.0.0.0', port=3000)