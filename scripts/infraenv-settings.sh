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
  ASSISTED_AGENT_SELECTOR=${ASSISTED_AGENT_SELECTOR:-"atlanta"}
  read -p "Would you like to change the name of the cluster deployment Default->[baremetal-testing]: " CLUSTER_DEPLOYMENT
  CLUSTER_DEPLOYMENT=${CLUSTER_DEPLOYMENT:-"baremetal-testing"}
  read -p "Would you like to change agent label Default->[dc]: " ASSISTED_AGENT_LABEL
  ASSISTED_AGENT_LABEL=${ASSISTED_AGENT_LABEL:-"dc"}
fi

cat << EOF > ${CLUSTER_DEPLOYMENT}/03-deployment/03-assisted-installer-infraenv.yaml
---
apiVersion: agent-install.openshift.io/v1beta1
kind: InfraEnv
metadata:
  name: ${CLUSTER_DEPLOYMENT}-infraenv
  namespace: assisted-installer
spec:
  clusterRef:
    name: ${CLUSTER_DEPLOYMENT}
    namespace: assisted-installer
  sshAuthorizedKey: "$(cat $HOME/.ssh/id_rsa.pub)"
  agentLabelSelector:
    matchLabels:
      ${ASSISTED_AGENT_LABEL}: ${ASSISTED_AGENT_SELECTOR}
  pullSecretRef:
    name: assisted-deployment-pull-secret
EOF
