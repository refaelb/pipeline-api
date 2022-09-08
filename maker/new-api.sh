# project_name=$1
# namespace=$1
# varable_group=$1
# service_connection_name=$1 
# usernameRancher=$1 # this is the username of the user that will be created in Rancher
# passwordRancher=$1 # password for rancher user
# token=$2 
# clusterId=$3 #local
# username=$4 #username for azure devops
# password=$5 #password for the user azure devops
# userName=$6 #userName is the same as admin in azure devops

project_name=$1
namespace=$1
varable_group=$1
service_connection_name=$1 
usernameRancher=$1 # this is the username of the user that will be created in Rancher
passwordRancher=$1 # password for rancher user
token=token-kz4gq:x4dxtqdklp6vmtgqhr6mt6n5dk5c7g55ksp596rh9tmtb5dp255gsw
clusterId=local
username=LA349514 #username for azure devops
password=yrtzbf5mbp7rqc24yykac6oat6tempj7dvmrykr7x42ns53hz3ma #password for the user azure devops
userName=$2 #userName is the same as admin in azure devops
#################
# create rancher project #
##################################################################################################################################################33
# kubectl create ns $namespace

curl -k  -o logs/resProject.json --location --request POST 'https://rancher.branch-yesodot.org/v3/project?_replace=true' \
--header 'Authorization: Bearer '$token \
--header 'Content-Type: application/json' \
--data-raw '{
	"clusterId": "local",
    "enableProjectMonitoring": "false",
    "labels": {},
    "name":  "'"$project_name"'",
    "type": "project"
}'
project_id=`cat logs/resProject.json | jq -r '.id'`
echo $project_id
# if [ $project_id != null ]; then
#     echo "Project $project_name created"
# else
#     echo "Project $project_name already exists"
# #    exit 1
# fi
sleep 2

# create k8s namespace and connect to project
curl -Li -k -o logs/ns.txt  --location --request POST 'https://rancher.branch-yesodot.org/v3/clusters/local/namespace' \
--header 'Authorization: Bearer '"$token" \
--header 'Content-Type: application/json' \
--data-raw '{
    "clusterId": "local",
    "labels": {},
    "name":  "'"$namespace"'",
    "projectId":  "'"$project_id"'",
    "resourceQuota": null,
    "type": "namespace"
}'



echo "finish namespace to project connection"
sleep 2

##########################################
# create user in rancher
curl  -s -o logs/res.json -k --location --request POST 'https://rancher.branch-yesodot.org/v3/user' \
--header 'Authorization: Bearer '$token \
--header 'Content-Type: application/json' \
--data-raw '{
    "enabled": true,
    "mustChangePassword": true , 
    "password": "'"$passwordRancher"'",
    "type": "user",
    "username": "'"$usernameRancher"'"
}'
user_id=`cat logs/res.json | jq -r '.id'`
###
if [ $user_id != null ]; then
    echo "user  created"
else
    echo "user already exists"
#    exit 1
fi
sleep 2

###
# debug user_id 
user_id="local://"$user_id
echo $user_id
echo $project_id
############ad type user ###########
curl -k --location --request POST 'https://rancher.branch-yesodot.org/v3/globalrolebinding' \
--header 'Authorization: Bearer '$token \
--header 'Content-Type: application/json' \
--data-raw '{
  "globalRoleId": "user",
  "type": "globalRoleBinding",
  "userId": "'"$user_id"'"
  }'
sleep 2

###############################################################################################################################
########connect user to project##########
curl -k  --location --request POST 'https://rancher.branch-yesodot.org/v3/projectroletemplatebinding' \
--header 'Authorization: Bearer '$token \
--header 'Content-Type: application/json' \
--data-raw '{
    "projectId": "'"$project_id"'",
    "roleTemplateId": "project-owner",
    "type": "projectRoleTemplateBinding",
    "userPrincipalId": "'"$user_id"'"
}'

echo "finish rancher apis "



#############################################createUserK8s##############################################
chart_location='./charts/yesodot-auth'
helm_output="$(helm install -n $namespace $project_name-auth $chart_location --set project_name=$project_name)"
sa_name=$project_name-cd
echo $sa
secret=$(kubectl get sa $sa_name -n $namespace -o=jsonpath={.secrets[*].name})
sa=` kubectl get secret  $secret -n $namespace -o json | jq '.data' | jq -c 'del(.namespace)' | sed  's/ca.crt/serviceAccountCertificate/g' | sed 's/token/apitoken/g' | sed 's/{//g' | sed 's/}//g' `

echo $sa



#############################################azureDevops################################################
sleep 4 
echo "start azureDevops"
 # create An AzureDevops project
curl -o logs/createproject.txt -Li -u "${username}:${password}" --location --request POST 'https://dev.azure.com/yesodot/_apis/projects?api-version=6.0' \
-H  'Content-Type: application/json' \
--data-raw '{
  "name": "'${project_name}'",
  "description": "api create project",
  "capabilities": {
    "versioncontrol": {
      "sourceControlType": "Git"
    },
    "processTemplate": {
      "templateTypeId": "6b724908-ef14-45cf-84f8-768b5384da45"
    }
  }
}'

echo "Create project: $project_name"
###########################################
sleep 3
# Create a k8s service connection
curl -o logs/createsa.txt   -u "${username}:${password}" --location --request POST 'https://dev.azure.com/yesodot/'${project_name}'/_apis/serviceendpoint/endpoints?api-version=5.0-preview.2' \
--header 'Content-Type: application/json' \
--data-raw '{
    "authorization": {
        "parameters": {
            '"$sa"'
            
            }
                ,"scheme": "Token"},"createdBy": {},"data": {"authorizationType": "ServiceAccount"},"isShared": false,"name": "'"$service_connection_name"'","owner": "library","type": "kubernetes","url": "https://yesodotaks-11164d2b.hcp.northeurope.azmk8s.io:443","administratorsGroup": null,"description": "","groupScopeId": null,"operationStatus": null,"readersGroup": null,"serviceEndpointProjectReferences": [{"description": "","name": "'"$service_connection_name"'","projectReference": {"id": "7af45079-4b1d-432c-a9a3-97428b546ee3","name": "'"$project_name"'"}}]}'
echo "Create service connection: $service_connection_name"
###########################################33
# sleep 2

# Create a variable group
curl -o logs/createvarable.txt -Li -u "${username}:${password}" --location --request POST 'https://dev.azure.com/yesodot/'${project_name}'/_apis/distributedtask/variablegroups?api-version=5.0-preview.1' \
--header 'Content-Type: application/json' \
--data-raw '{
  "variables": {
    "Authorization": {
      "value": "password",
      "isSecret": true
    },
    "url": {
      "value": "https://harbor.branch-yesodot.org/api/chartrepo/library/charts"
    },
    "values_path": {
      "value": "test-values"
    }
  },
  "type": "Vsts",
  "name": "'${varable_group}'",
  "description": "A test variable group"
}'

echo "Create variable group: $varable_group"
###############################################
sleep 2

curl -o logs/admin1.txt  -u "${username}:${password}" -k  --location --request  GET 'https://dev.azure.com/yesodot/_apis/projects/'${project_name} | jq -r '.id'
group_id=$(cat logs/admin1.txt | jq -r '.id')
echo $group_id
sleep 2
####
curl -o logs/admin2.txt -u "${username}:${password}" -k --location --request  GET 'https://vssps.dev.azure.com/yesodot/_apis/graph/descriptors/'${group_id}'?api-version=5.0-preview.1' | jq -r '.value'
scopeDescriptor=$(cat logs/admin2.txt | jq -r '.value')
echo $scopeDescriptor
sleep 2
######
curl -o logs/admin3.txt -u "${username}:${password}"    -k --location --request GET 'https://vssps.dev.azure.com/yesodot/_apis/Graph/groups?scopeDescriptor='${scopeDescriptor} |  jq -r '.value[] | [.descriptor, .displayName]' | grep -B 1 "Project Administrators" | grep -v "Project Administrators" | awk '{print $1}' | sed 's/\,//g' | sed 's/\"//g'
groupId=$(cat admin3.txt |  jq -r '.value[] | [.descriptor, .displayName]' | grep -B 1 "Project Administrators" | grep -v "Project Administrators" | awk '{print $1}' | sed 's/\,//g' | sed 's/\"//g')
echo $groupId
sleep 2
######
curl  -o logs/admin4.txt -u "${username}:${password}"  -k --location --request POST 'https://vssps.dev.azure.com/yesodot/_apis/graph/users?groupDescriptors='{$groupId}'&api-version=5.1-preview.1' \
--header "Content-Type: application/json" \
--data-raw "{'principalName': '"${userName}"@greendreamteam.onmicrosoft.com'}"

echo "add user: $userName to admin project $project_name"
