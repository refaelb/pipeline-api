# export $(cat .env | xargs)

project_name=$1
# repo_id=$2
username=$2
password=$3

curl -o repo-id.txt --location -u "${username}:${password}"  --request GET 'https://dev.azure.com/yesodot/'${project_name}'/_apis/git/repositories' 
repo_id=$(cat repo-id.txt | jq .value[].id)
sleep 2

curl --location -u "${username}:${password}"  --request POST 'https://dev.azure.com/yesodot/'{$project_name}'/_apis/pipelines?api-version=6.1-preview.1' \
--header 'Content-Type: application/json' \
--data-raw '{
  "folder": null,
  "name": "cd-pipeline-yaml",
  "configuration": {
    "type": "yaml",
    "path": "/azure-pipeline/azure-pipelines.yml",
    "repository": {
      "id": '{$repo_id}',
      "name": '{$project_name}'',
      "type": "azureReposGit"
    }
  }
}'