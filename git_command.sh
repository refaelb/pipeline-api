# if [ ! -f .env ]
# then
#   export $(cat .env | xargs)
# fi
export $(cat .env | xargs)

project_name=$1
token=$TOKEN
azureuser=$ADMINUSER

cd ./../projects/$project_name
git init .
# git remote add origin   https://{$azureuser}:{$token}@dev.azure.com/yesodot/migration1/_git/migration1
# git remote add origin   https://Ontario-135:4dks6lvuaq7plwo4g3vaphd4w2yxut6mf2o3d5dpbgaoywahczzq@dev.azure.com/yesodot/migration1/_git/migration1
git remote add origin   https://$azureuser:$token@dev.azure.com/yesodot/$project_name/_git/$project_name
git add .
git commit -m "api add the files "
git push --set-upstream origin master 

