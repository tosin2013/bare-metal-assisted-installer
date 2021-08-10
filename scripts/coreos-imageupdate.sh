#!/bin/bash
#####
### OpenShift pre-leases
### https://openshift-release.apps.ci.l2s4.p1.openshiftapps.com/
### Openshift relases
### https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/latest/latest/
#####
export OPENSHIFT_VERSION="4.8.2"
export OPENSHIFT_VERSION_TAG="4.8"
export RHCOS_VERSION="48.84.202107271439-0"
export RHCOS_ROOTFS_URL="https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/latest/latest/rhcos-live-rootfs.x86_64.img"
export RHCOS_ISO_URL="https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/latest/latest/rhcos-live.x86_64.iso"

####
## Pre-Release urls
## export OPENSHIFT_VERSION="4.8.0-rc.3"
##
## export RHCOS_ROOTFS_URL="https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/pre-release/${OPENSHIFT_VERSION}/rhcos-live-rootfs.x86_64.img"
## export RHCOS_ISO_URL="https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/pre-release/${OPENSHIFT_VERSION}/rhcos-${OPENSHIFT_VERSION}-x86_64-live.x86_64.iso"
####

cat << EOF > deploy-samplecluster/02-config/image-versions.yaml
apiVersion: agent-install.openshift.io/v1beta1
kind: AgentServiceConfig
metadata:
  name: agent
spec:
  osImages:
    - openshiftVersion: "${OPENSHIFT_VERSION_TAG}"
      rootFSUrl: >-
        ${RHCOS_ROOTFS_URL}
      url: >-
        ${RHCOS_ISO_URL}
      version: ${RHCOS_VERSION}
EOF

