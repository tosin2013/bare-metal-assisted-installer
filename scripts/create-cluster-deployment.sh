#!/bin/bash 


if [ -d $(pwd)/deploy-samplecluster ]; 
then 
  read -p "Would you like to change the name of the cluster deployment Default->[baremetal-testing]: " CLUSTER_DEPLOYMENT
  CLUSTER_DEPLOYMENT=${CLUSTER_DEPLOYMENT:-"baremetal-testing"}
  cp -r $(pwd)/deploy-samplecluster  $(pwd)/${CLUSTER_DEPLOYMENT}
  echo "export CLUSTER_DEPLOYMENT=${CLUSTER_DEPLOYMENT}" > ${HOME}/env.variables

else 
  echo "please run $0 in the $pwd/bare-metal-assisted-installer directory"
  exit 1
fi 