#!/bin/bash 
if [ -f ${HOME}/env.variables ];
then 
  source  ${HOME}/env.variables
else
  read -p "Would you like to change the cluster deployment name This changes default name for eah cluster deployment. Default->[baremetal-testing]: " CLUSTER_DEPLOYMENT
  CLUSTER_DEPLOYMENT=${CLUSTER_DEPLOYMENT:-"baremetal-testing"}
fi


read -p "Would you like to delete the deployment ${CLUSTER_DEPLOYMENT}: " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Removing Deployments"
    kustomize build  ${CLUSTER_DEPLOYMENT}/03-deployment | oc delete -f - 
    echo "Removing Configs"
    kustomize build  ${CLUSTER_DEPLOYMENT}/02-config | oc delete -f - 
    echo "Removing Operators"
    kustomize build  ${CLUSTER_DEPLOYMENT}/01-operators | oc delete -f - 
fi

