from inspect import ArgSpec
from re import I
from sys import argv
from flask import Flask, request ,Response
import json
import yaml
# import git 
import os


valuse="""
name: {service_name}
replicaCount: {service_replica_count}

images:
  PullSecrets: {service_pull}
  repository: {service_repo}
  tag: {service_tag}

service:
 ports: {service_port}

volume:
    enable: {volume_status}
  - name: {volume_name}
    type: volumeClaim
    claimName: {volume_name}"-claim"
    mounts:
      - mountPath: {volume_mount}
        subPath: {volume_path}

config:
  configmaps: {configmap}

ingress:
  enabled: {ingress_status}
  annotations: 
    myannotation: test
  hosts:
  - host: {ingress_host}
    paths:
      - path: {ingress_path}
        service: {service_name}
        port: 80
"""

helmfile="""
environments:
  dev:
  prod:

repositories:
- name: yesodot
  url: https://harborreg-2.northeurope.cloudapp.azure.com/chartrepo/library
  username: {{ requiredEnv "HARBOR_USER" }}
  password: {{ requiredEnv "HARBOR_PASSWORD" }}

releases:
# - name: {service_name}
#   namespace: {project_name}
  chart: yesodot/common
  version: {{ requiredEnv "COMMON_VERSION" | default "0.5.2" }}
  values:
    - ../{{ .Environment.Name }}-values/Back-Service.yaml
  installed: true 
"""


app = Flask(__name__)

@app.route('/pipline_api/create', methods=['POST'])
def pipline_api():
    data = (request.data)
    res = validate(data)
    response = Response(res)
    return response


def validate(data):
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
        service_replica_count=(json_data["service"][service]["replicacount"])
        service_port=(json_data["service"][service]["port"])
        volume_name=(json_data["services"][service]["volumes"]["name"])
        volume_mount=(json_data["services"][service]["volumes"]["mount_path"])
        volume_sub=(json_data["services"][service]["volumes"]["sub_path"])
        ingress_status=(json_data["services"][service]["ingress"]["enable"])
        ingress_path=(json_data["services"][service]["ingress"]["path"])
        ingress_host=(json_data["services"][service]["ingress"]["host"])
        write(project_name, service_name,pullSecrets, service_repo, service_tag, volume_mount, volume_sub, volume_name,configmap,ingress_path, ingress_status,ingress_host,service_port, service_replica_count)
    helmfile_write(project_name, azure_user)
    return  project_name, service_name, service_repo, service_tag, volume_mount, volume_sub, volume_name,ingress_path, ingress_status,ingress_host,service_port, service_replica_count, pullSecrets,configmap

##create values.yaml files
def write( project_name, service_name,pullSecrets, service_repo, service_tag, volume_mount, volume_sub, volume_name,configmap,ingress_path, ingress_status,ingress_host,service_port, service_replica_count):
    with open ("./../"+project_name+"/valuse/"+service_name+"-valuse.yaml","a+") as f :
        var_list = yaml.load(valuse, Loader=yaml.FullLoader)
        yaml.dump(var_list, f.format( service_name,pullSecrets, service_repo, service_tag, volume_mount, volume_sub, volume_name,configmap,ingress_path, ingress_status,ingress_host,service_port, service_replica_count))

##create helmfile
def helmfile_write(project_name, azure_user):
    with open ("./../"+project_name+"/helmfile/helmfile.yaml","a+") as f :
        var_list = yaml.load(valuse, Loader=yaml.FullLoader)
        yaml.dump(var_list, f)
    maker(project_name, azure_user)
    git(project_name)

##maker project api
def maker(project_name ,azure_user):
    os.system("chmod +x maker/new-api.sh")
    os.system("./maker/new-api.sh {}".format(project_name ,azure_user))

##push values & helmfile to azure repo
def git(project_name):
    os.system("chnod +x git_command.sh ")
    os.system("./git_command.sh {}".format(project_name))


            


if __name__ == '__main__':
    app.run(debug=True)