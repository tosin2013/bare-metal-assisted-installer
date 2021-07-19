#!/bin/bash

export ASSISTED_AGENT_SELECTOR="atlanta"
export CLUSTER_DEPLOYMENT="baremetal-testing"
export CLUSTER_DOMAIN="example.com"
export ASSISTED_AGENT_LABEL="dc"

cat << EOF > deploy-samplecluster/03-deployment/02-assisted-installer-clusterdeployment.yaml
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
