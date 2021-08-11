#!/bin/bash

function checkforstring (){
  if grep -q ${1} "${HOME}/env.variables"; then
    echo "Updating ${1} ${2}"
    sed -i 's/export '${1}'=.*/export '${1}'='${2}'/' ${HOME}/env.variables
  else
sudo tee -a  ${HOME}/env.variables> /dev/null <<EOT
export ${1}=${2}
EOT
  fi
}

read -p "Would you like to change the AgentSelector is a label selector used for associating
                          relevant custom resources with this cluster. (Agent, BareMetalHost,
                          etc). Default->[atlanta]: " ASSISTED_AGENT_SELECTOR
ASSISTED_AGENT_SELECTOR=${ASSISTED_AGENT_SELECTOR:-"atlanta"}
read -p "Would you like to change the name of the cluster deployment Default->[baremetal-testing]: " CLUSTER_DEPLOYMENT
CLUSTER_DEPLOYMENT=${CLUSTER_DEPLOYMENT:-"baremetal-testing"}
read -p "Enter the cluster domain this will be used for dns. Default->[example.com]: " CLUSTER_DOMAIN
CLUSTER_DOMAIN=${CLUSTER_DOMAIN:-"example.com"}
read -p "Would you like to change agent label Default->[dc]: " ASSISTED_AGENT_LABEL
ASSISTED_AGENT_LABEL=${ASSISTED_AGENT_LABEL:-"dc"}


cat << EOF >  ${CLUSTER_DEPLOYMENT}/03-deployment/02-assisted-installer-clusterdeployment.yaml
apiVersion: hive.openshift.io/v1
kind: ClusterDeployment
metadata:
  name: ${CLUSTER_DEPLOYMENT}
  namespace: assisted-installer
spec:
  baseDomain: ${CLUSTER_DOMAIN}
  clusterName: ${CLUSTER_DEPLOYMENT}
  controlPlaneConfig:
    servingCertificates: {}
  installed: false
  clusterInstallRef:
    group: extensions.hive.openshift.io
    kind: AgentClusterInstall
    name: ${CLUSTER_DEPLOYMENT}-aci
    version: v1beta1
  platform:
    agentBareMetal:
      agentSelector:
        matchLabels:
          ${ASSISTED_AGENT_LABEL}: "${ASSISTED_AGENT_SELECTOR}"
  pullSecretRef:
    name: assisted-deployment-pull-secret
EOF

if [ -f ${HOME}/env.variables ];
then 
    checkforstring ASSISTED_AGENT_SELECTOR ${ASSISTED_AGENT_SELECTOR}
    checkforstring CLUSTER_DEPLOYMENT ${CLUSTER_DEPLOYMENT}
    checkforstring CLUSTER_DOMAIN ${CLUSTER_DOMAIN}
    checkforstring ASSISTED_AGENT_LABEL ${ASSISTED_AGENT_LABEL}
fi

