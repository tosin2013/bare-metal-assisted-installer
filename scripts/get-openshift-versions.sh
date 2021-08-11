#!/bin/bash 


OPENSHIFT_VERSION=$(curl -sL https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/release.txt | grep Version | head -1 | awk '{print $2}')
RHCOS_VERSION=$(curl -sL https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/release.txt | grep -Eo '[0-9]{2}.[0-9]{2}.[0-9]{12}-[0]')
OPENSHIFT_VERSION_TAG=$(sed 's/.\{2\}$//' <<< "${OPENSHIFT_VERSION}" )

sudo tee -a ${HOME}/env.variables > /dev/null <<EOT
export OPENSHIFT_VERSION=${OPENSHIFT_VERSION}
export OPENSHIFT_META_TAG="openshift-v${OPENSHIFT_VERSION}"
export RHCOS_VERSION=${RHCOS_VERSION}
export OPENSHIFT_VERSION_TAG=${OPENSHIFT_VERSION_TAG}
EOT

cat  ${HOME}/env.variables
echo "source  ${HOME}/env.variables"