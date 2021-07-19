#!/bin/bash
# OpenShift pre-leases
# https://openshift-release.apps.ci.l2s4.p1.openshiftapps.com/
set -xe

if [ ! -f ${HOME}/.ssh/id_rsa ];
then 
  echo "please run ssh-keygen then restart script"
  exit 1
fi

export OPENSHIFT_VERSION="4.8.0-rc.3"
export CLUSTER_DOMAIN="tosins-lab.com"
export CLUSTER_NAME="baremetal-testing"

cat << EOF > ./environment.sh
RHCOS_VERSION="48.84.202107040900-0"
RHCOS_ROOTFS_URL="https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/pre-release/${OPENSHIFT_VERSION}/rhcos-live-rootfs.x86_64.img"
RHCOS_ISO_URL="https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/pre-release/${OPENSHIFT_VERSION}/rhcos-${OPENSHIFT_VERSION}-x86_64-live.x86_64.iso"
ASSISTED_SVC_PVC="20Gi"
ASSISTED_SVC_IMG="quay.io/ocpmetal/assisted-service-index:latest"
ASSISTED_AGENT_LABEL="dc"
ASSISTED_AGENT_SELECTOR="atlanta"
CLUSTER_VERSION="4.8"
CLUSTER_IMAGE="quay.io/openshift-release-dev/ocp-release:${OPENSHIFT_VERSION}-x86_64"
CLUSTER_NAME="${CLUSTER_NAME}"
CLUSTER_DOMAIN="${CLUSTER_DOMAIN}"
CLUSTER_NET_TYPE="OpenShiftSDN"
CLUSTER_CIDR_NET="10.128.0.0/14"
CLUSTER_CIDR_SVC="172.30.0.0/16"
CLUSTER_HOST_NET="10.0.1.0/24"
CLUSTER_HOST_PFX="23"
CLUSTER_WORKER_HT="Enabled"
CLUSTER_WORKER_COUNT="0"
CLUSTER_MASTER_HT="Enabled"
CLUSTER_MASTER_COUNT="0"
CLUSTER_SSHKEY='$(cat ~/.ssh/id_rsa.pub)'
CLUSTER_DEPLOYMENT="$CLUSTER_NAME"
CLUSTER_IMG_REF="openshift-v4.8.0"
MANIFEST_DIR="./deploy-$CLUSTER_NAME"
SSH_PRIVATE_KEY="$HOME/.ssh/id_rsa"
EOF

source environment.sh