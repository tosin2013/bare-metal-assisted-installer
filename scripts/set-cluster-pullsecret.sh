#!/bin/bash 

if [ ! -f $HOME/pullsecert.txt ];
then 
  echo "add pullsecert.txt to home directory"
  echo "$HOME"
  exit 1
fi 

if [ -f ${HOME}/env.variables ];
then 
  source  ${HOME}/env.variables
else
  export CLUSTER_DEPLOYMENT="deploy-samplecluster"
fi



cat << EOF > ${CLUSTER_DEPLOYMENT}/02-config/03-assisted-installer-secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: assisted-deployment-pull-secret
  namespace: assisted-installer
stringData:
  .dockerconfigjson: '$(cat $HOME/pullsecert.txt)'
EOF
