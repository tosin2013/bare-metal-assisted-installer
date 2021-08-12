#!/bin/bash

if [ ! -f $HOME/.ssh/id_rsa.pub ];
then 
  echo "Genereate $HOME/.ssh/id_rsa key"
  echo "use ssh-keygen"
  exit 1
fi 

if [ -f ${HOME}/env.variables ];
then 
  source  ${HOME}/env.variables
else
  export OPENSHIFT_META_TAG="openshift-v4.8.4"
fi

read -p "Would you like to change the clusterNetwork This changes IP address blocks for pods. Default->[10.128.0.0/14]: " CLUSTER_NETWORK
CLUSTER_NETWORK=${CLUSTER_NETWORK:-"10.128.0.0/14"}
read -p "Would you like to change the clusterNetwork  hostPrefix This changes the subnet prefix length to assign to each individual node.  Default->[23]: " CLUSTER_NETWORK_HOST_PREFIX
CLUSTER_NETWORK_HOST_PREFIX=${CLUSTER_NETWORK_HOST_PREFIX:-"23"}
read -p "Would you like to change the serviceNetwork This changes the IP address block for services.  Default->[172.30.0.0/16]: " SERVICE_NETWORK
SERVICE_NETWORK=${SERVICE_NETWORK:-"172.30.0.0/16"}
read -p "Would you like to change the machineNetwork This changes the IP address blocks for machines. Default->[10.0.0.0/16]: " MACHINE_NETWORK
MACHINE_NETWORK=${MACHINE_NETWORK:-"10.0.0.0/16"}

if [ -z ${CLUSTER_DEPLOYMENT} ];
then 
  read -p "Would you like to change the cluster deployment name This changes default name for eah cluster deployment. Default->[baremetal-testing]: " CLUSTER_DEPLOYMENT
  CLUSTER_DEPLOYMENT=${CLUSTER_DEPLOYMENT:-"baremetal-testing"}
fi 


cat << EOF >  ${CLUSTER_DEPLOYMENT}/03-deployment/01-assisted-installer-agentclusterinstall.yaml
---
apiVersion: extensions.hive.openshift.io/v1beta1
kind: AgentClusterInstall
metadata:
  name: ${CLUSTER_DEPLOYMENT}-aci
  namespace: assisted-installer
spec:
  clusterDeploymentRef:
    name: ${CLUSTER_DEPLOYMENT}
  imageSetRef:
    name: ${OPENSHIFT_META_TAG}
  networking:
    clusterNetwork:
      - cidr: "${CLUSTER_NETWORK}"
        hostPrefix: ${CLUSTER_NETWORK_HOST_PREFIX}
    serviceNetwork:
      - "${SERVICE_NETWORK}"
    machineNetwork:
      - cidr: "${MACHINE_NETWORK}"
  provisionRequirements:
    controlPlaneAgents: 1
  sshPublicKey: "$(cat $HOME/.ssh/id_rsa.pub)"
EOF
