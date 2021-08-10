#!/bin/bash
# OpenShift pre-leases
# https://openshift-release.apps.ci.l2s4.p1.openshiftapps.com/

export OPENSHIFT_META_TAG="openshift-v4.8.3"
export OPENSHIFT_VERSION="4.8.3"
export RHCOS_ROOTFS_URL="quay.io/openshift-release-dev/ocp-release:${OPENSHIFT_VERSION}-x86_64"
####
## Pre-Release urls
## export OPENSHIFT_VERSION="4.8.0-rc.3"
##
## export RHCOS_ROOTFS_URL="quay.io/openshift-release-dev/ocp-release:${OPENSHIFT_VERSION}-x86_64"
####



cat << EOF > deploy-samplecluster/02-config/02-assisted-installer-clusterimageset.yaml
apiVersion: hive.openshift.io/v1
kind: ClusterImageSet
metadata:
  name: ${OPENSHIFT_META_TAG}
  namespace: assisted-installer
spec:
  releaseImage: ${RHCOS_ROOTFS_URL}

EOF
