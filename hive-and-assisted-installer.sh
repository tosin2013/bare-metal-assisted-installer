#!/bin/bash
set  -xe
source enviornment.sh


cat << EOF > $MANIFEST_DIR/01-operators/02-hive-operator.yaml
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: hive-operator
  namespace: openshift-operators
spec:
  channel: alpha
  installPlanApproval: Automatic
  name: hive-operator
  source: community-operators
  sourceNamespace: openshift-marketplace
  startingCSV: $HIVE_CSV
EOF

cat << EOF > $MANIFEST_DIR/01-operators/03-assisted-installer-catsource.yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: assisted-installer
  labels:
    name: assisted-installer
---
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: assisted-service
  namespace: openshift-marketplace
spec:
  sourceType: grpc
  image: $ASSISTED_SVC_IMG
EOF

cat << EOF > $MANIFEST_DIR/01-operators/04-assisted-installer-operator.yaml
---
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: assisted-service-operator
  namespace: assisted-installer
spec:
  targetNamespaces:
  - assisted-installer
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: assisted-service-operator
  namespace: assisted-installer
spec:
  channel: alpha
  installPlanApproval: Automatic
  name: assisted-service-operator
  source: assisted-service
  sourceNamespace: openshift-marketplace
EOF

oc create -f $MANIFEST_DIR/01-operators/02-hive-operator.yaml

oc get pods -n openshift-marketplace
oc get pods -n openshift-operators

oc create -f $MANIFEST_DIR/01-operators/03-assisted-installer-catsource.yaml
oc create -f $MANIFEST_DIR/01-operators/04-assisted-installer-operator.yaml

oc get pods -n openshift-marketplace
oc get pods -n assisted-installer


cat << EOF > $MANIFEST_DIR/02-config/01-assisted-installer-agentserviceconfig.yaml
apiVersion: agent-install.openshift.io/v1beta1
kind: AgentServiceConfig
metadata:
  name: agent
spec:
  databaseStorage:
    accessModes:
      - ReadWriteOnce
    resources:
      requests:
        storage: $ASSISTED_SVC_PVC
  filesystemStorage:
    accessModes:
      - ReadWriteOnce
    resources:
      requests:
        storage: $ASSISTED_SVC_PVC
  osImages:
    - openshiftVersion: "$CLUSTER_VERSION"
      rootFSUrl: >-
        $RHCOS_ROOTFS_URL
      url: >-
        $RHCOS_ISO_URL
      version: $RHCOS_VERSION
EOF
oc create -f $MANIFEST_DIR/02-config/01-assisted-installer-agentserviceconfig.yaml

oc get pods -n assisted-installer


cat << EOF > $MANIFEST_DIR/02-config/02-assisted-installer-clusterimageset.yaml
apiVersion: hive.openshift.io/v1
kind: ClusterImageSet
metadata:
  name: $CLUSTER_IMG_REF
  namespace: assisted-installer
spec:
  releaseImage: $CLUSTER_IMAGE
EOF
oc create -f $MANIFEST_DIR/02-config/02-assisted-installer-clusterimageset.yaml


PULL_SECRET=$(cat pull-secret.txt | jq -R .)

cat << EOF > $MANIFEST_DIR/02-config/03-assisted-installer-secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: assisted-deployment-pull-secret
  namespace: assisted-installer
stringData:
  .dockerconfigjson: $PULL_SECRET
EOF

oc create -f $MANIFEST_DIR/02-config/03-assisted-installer-secrets.yaml

oc create secret generic assisted-deployment-ssh-private-key \
  -n assisted-installer  \
  --from-file=ssh-privatekey=$SSH_PRIVATE_KEY

cat << EOF > $MANIFEST_DIR/03-deployment/01-assisted-installer-agentclusterinstall.yaml
---
apiVersion: extensions.hive.openshift.io/v1beta1
kind: AgentClusterInstall
metadata:
  name: $CLUSTER_NAME-aci
  namespace: assisted-installer
spec:
  clusterDeploymentRef:
    name: $CLUSTER_NAME
  imageSetRef:
    name: $CLUSTER_IMG_REF
  networking:
    clusterNetwork:
      - cidr: "$CLUSTER_CIDR_NET"
        hostPrefix: $CLUSTER_HOST_PFX
    serviceNetwork:
      - "$CLUSTER_CIDR_SVC"
    machineNetwork:
      - cidr: "$CLUSTER_HOST_NET"
  provisionRequirements:
    controlPlaneAgents: 1
  sshPublicKey: "$CLUSTER_SSHKEY"
EOF

oc create -f $MANIFEST_DIR/03-deployment/01-assisted-installer-agentclusterinstall.yaml

cat << EOF > $MANIFEST_DIR/03-deployment/02-assisted-installer-clusterdeployment.yaml
---
apiVersion: hive.openshift.io/v1
kind: ClusterDeployment
metadata:
  name: $CLUSTER_NAME
  namespace: assisted-installer
spec:
  baseDomain: $CLUSTER_DOMAIN
  clusterName: $CLUSTER_NAME
  controlPlaneConfig:
    servingCertificates: {}
  installed: false
  clusterInstallRef:
    group: extensions.hive.openshift.io
    kind: AgentClusterInstall
    name: $CLUSTER_NAME-aci
    version: v1beta1
  platform:
    agentBareMetal:
      agentSelector:
        matchLabels:
          $ASSISTED_AGENT_LABEL: "$ASSISTED_AGENT_SELECTOR"
  pullSecretRef:
    name: assisted-deployment-pull-secret
EOF

oc create -f $MANIFEST_DIR/03-deployment/02-assisted-installer-clusterdeployment.yaml

cat << EOF > $MANIFEST_DIR/03-deployment/03-assisted-installer-infraenv.yaml
---
apiVersion: agent-install.openshift.io/v1beta1
kind: InfraEnv
metadata:
  name: $CLUSTER_NAME-infraenv
  namespace: assisted-installer
spec:
  clusterRef:
    name: $CLUSTER_NAME
    namespace: assisted-installer
  sshAuthorizedKey: "$CLUSTER_SSHKEY"
  agentLabelSelector:
    matchLabels:
      $ASSISTED_AGENT_LABEL: $ASSISTED_AGENT_SELECTOR
  pullSecretRef:
    name: assisted-deployment-pull-secret
EOF

oc create -f $MANIFEST_DIR/03-deployment/03-assisted-installer-infraenv.yaml

DOWNLOAD_URL=$(oc get infraenv $CLUSTER_NAME-infraenv -o jsonpath='{.status.isoDownloadURL}' -n assisted-installer)
echo $DOWNLOAD_URL
curl -k -L "$DOWNLOAD_URL" -o ai-install.iso