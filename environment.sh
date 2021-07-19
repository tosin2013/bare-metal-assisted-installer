export RHCOS_VERSION="48.84.202107040900-0"
export RHCOS_ROOTFS_URL="https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/pre-release/4.8.0-rc.3/rhcos-live-rootfs.x86_64.img"
export RHCOS_ISO_URL="https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/pre-release/4.8.0-rc.3/rhcos-4.8.0-rc.3-x86_64-live.x86_64.iso"
export ASSISTED_SVC_PVC="20Gi"
export ASSISTED_SVC_IMG="quay.io/ocpmetal/assisted-service-index:latest"
export ASSISTED_AGENT_LABEL="dc"
export ASSISTED_AGENT_SELECTOR="atlanta"
export CLUSTER_VERSION="4.8"
export CLUSTER_IMAGE="quay.io/openshift-release-dev/ocp-release:4.8.0-rc.3-x86_64"
export CLUSTER_NAME="baremetal-testing"
export CLUSTER_DOMAIN="tosins-lab.com"
export CLUSTER_NET_TYPE="OpenShiftSDN"
export CLUSTER_CIDR_NET="10.128.0.0/14"
export CLUSTER_CIDR_SVC="172.30.0.0/16"
export CLUSTER_HOST_NET="10.0.1.0/24"
export CLUSTER_HOST_PFX="23"
export CLUSTER_WORKER_HT="Enabled"
export CLUSTER_WORKER_COUNT="0"
export CLUSTER_MASTER_HT="Enabled"
export CLUSTER_MASTER_COUNT="0"
export CLUSTER_SSHKEY='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCyxzOYrW+DLkF2w+LIY3raN+t7kSL6p5czsNPtgaqUfLpVdCIQ6TMJ+pWuskGyOmvL7Kz0AO+e969q462tcwQpm6d0uHltLomiZYb4vjWzcG3IAOtYGJ11sfvv3dJt8PbTrSvEo06e+uJhgn168xIp9GPgmU3C9twsfmljOHqmSKLDR4WJUyZiSqOyK5dhBtmlIszEgN+K2Vzn3QbaAq71rxTlEzaEXKyetgse0XYvfW5lEQsWIfHol15kFS/PzEhV1Ph4wKqesy51AWvnKjUZYOnm0TfvJ55ywWt/h29+J69KCDNjLaWLNrmd6OQWMe8i9HsDuFeA+Ggk9OZpeJtY9A0qpi2mEE0pIwfQNF9kYRp/6A3ko0Qvb14UV4Mn3HDj4r8d1dfEAi7DvPpair0Pc++UeY6gRs4HzgpHqqUFYxMeOXVzoNP9ixWN/Tx0G0Uc7INm56AJ+fgAOvDB8YOkDLMkDCB1sZR/ASClZyiOwj0d8KWaBgoq3IBdHK8tRVE= tosin@tosins-fedora'
export CLUSTER_DEPLOYMENT="baremetal-testing"
export CLUSTER_IMG_REF="openshift-v4.8.0"
export MANIFEST_DIR="./deploy-samplecluster"
export SSH_PRIVATE_KEY="/home/tosin/.ssh/id_rsa"