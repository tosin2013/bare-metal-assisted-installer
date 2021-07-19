#!/bin/bash 

if [ ! -f $HOME/pullsecert.txt ];
then 
  echo "add pullsecert.txt to home directory"
  echo "$HOME"
  exit 1
fi 


cat << EOF > deploy-samplecluster/02-config/03-assisted-installer-secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: assisted-deployment-pull-secret
  namespace: assisted-installer
stringData:
  .dockerconfigjson: '$(cat $HOME/pullsecert.txt)'
EOF
