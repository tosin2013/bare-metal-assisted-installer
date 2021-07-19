#!/bin/bash

if [ ! -f $HOME/.ssh/id_rsa.pub ];
then 
  echo "Genereate $HOME/.ssh/id_rsa key"
  echo "use ssh-keygen"
  exit 1
fi 

export OPENSHIFT_META_TAG="openshift-v4.8.0"
export CLUSTER_NETWORK="10.128.0.0/14"
export CLUSTER_NETWORK_HOST_PREFIX="23"
export SERVICE_NETWORK="172.30.0.0/16"
export MACHINE_NETWORK="10.0.1.0/24"
export CLUSTER_DEPLOYMENT="baremetal-testing"

cat << EOF > deploy-samplecluster/03-deployment/01-assisted-installer-agentclusterinstall.yaml
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
