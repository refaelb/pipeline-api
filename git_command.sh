export $(cat .env | xargs)

project_name=$1
token=$PASSWORD
azureuser=$USERNAME

cd ./../projects/$project_name
git init .
git remote add origin   https://$azureuser:$token@dev.azure.com/yesodot/$project_name/_git/$project_name
git add .
git commit -m "api add the files "
git push --set-upstream origin master 

