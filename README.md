# Deploy Bare-Metal Clusters via Hive and Assisted Installer
The below instructions shows how to eploy a single node bare metal Openshift Cluster. Native OpenShift or CRC may be used when running the instuctions below. 

# Requirements 
* kustomize
```
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
sudo mv kustomize /usr/local/bin 
```
* OpenShift CLI
```
curl -OL https://raw.githubusercontent.com/tosin2013/openshift-4-deployment-notes/master/pre-steps/configure-openshift-packages.sh
chmod +x configure-openshift-packages.sh
./configure-openshift-packages.sh -i
```
* OpenShift or CRC

## Directions 
```
git clone https://github.com/tosin2013/bare-metal-assisted-installer.git
```
### cd into directory
```
cd bare-metal-assisted-installer
```

### Generate sshkey for clusters
`ssh-keygen`

### Create Deployment folder 
> Once the deployment has been complete you can check in the code into git.
```
./scripts/create-cluster-deployment.sh
```

### export Deployment name
```
$ source $HOME/env.variables 

$ echo  echo $CLUSTER_DEPLOYMENT
baremetal-testing
```

### Deploy Operators
```
kustomize build  ${CLUSTER_DEPLOYMENT}/01-operators | oc create -f - 
```

**Wait fo operators to load** 
```
 ./scripts/operator-status.sh
```

### Configure the env.variables for the scripts below
```
$ ./scripts/get-openshift-versions.sh
```

### Edit scripts and update config
**edit and run scripts/cluster-imageset.sh** 
* You can find release versions [here](https://openshift-release.apps.ci.l2s4.p1.openshiftapps.com/)
* You may also check the lastest stable release infomration [here]( https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/release.txt)

> If you want to target a specific release manually update the variables in the script.
```
$ vi scripts/cluster-imageset.sh
export OPENSHIFT_META_TAG="openshift-v4.8.4"
export OPENSHIFT_VERSION="4.8.4"
```
> If you want to deploy the latest version of Openshift using the get-openshift-version.sh run the script below.
```
$ ./scripts/cluster-imageset.sh
```


**edit and run scripts/coreos-imageupdate.sh** 
> If you want to target a specific release manually update the variables in the script.
```
$ vi ./scripts/coreos-imageupdate.sh
export OPENSHIFT_VERSION="4.8.4"
export OPENSHIFT_VERSION_TAG="4.8"
export RHCOS_VERSION=48.84.202107301701-0
```

> If you want to deploy the latest version of Openshift using the get-openshift-version.sh run the script below.
```
$ ./scripts/coreos-imageupdate.sh
```

**edit and run scripts/set-cluster-pullsecret.sh**   

https://cloud.redhat.com/openshift/install/metal/user-provisioned

```
vim $HOME/pullsecert.txt
./scripts/set-cluster-pullsecret.sh
```

**validate kustomize results**
```
kustomize build  ${CLUSTER_DEPLOYMENT}/02-config
```

**Apply kustomize**
```
kustomize build  ${CLUSTER_DEPLOYMENT}/02-config | oc create -f - 
```

### Configure deployment 

**edit and run scripts/clusteragent-settings.sh** 
> If you want to target a specific release manually or change the default ssh key used update the variables in the script.
```
$ vi scripts/clusteragent-settings.sh
export OPENSHIFT_META_TAG="openshift-v4.8.3"
```

> If you want to deploy the latest version of Openshift using the get-openshift-version.sh run the script below.
```
./scripts/clusteragent-settings.sh
```

**run scripts/clusterdeployment-settings.sh** 
```
$ ./scripts/clusterdeployment-settings.sh
```

**run scripts/infraenv-settings.sh** 
```
./scripts/infraenv-settings.sh
```

**validate kustomize results**
```
kustomize build  ${CLUSTER_DEPLOYMENT}/03-deployment
```

**Apply kustomize**
```
kustomize build  ${CLUSTER_DEPLOYMENT}/03-deployment | oc create -f - 
```

**Wait for assisted-service pod**
```
./scripts/assisted-service-status.sh
```

## Provision baremetal node
**Get download URL**
```
export CLUSTER_DEPLOYMENT="baremetal-testing"
oc get infraenv ${CLUSTER_DEPLOYMENT}-infraenv -o jsonpath='{.status.isoDownloadURL}' -n assisted-installer
```

**Download iso**
```
DOWNLOAD_URL=$(oc get infraenv $CLUSTER_DEPLOYMENT-infraenv -o jsonpath='{.status.isoDownloadURL}' -n assisted-installer)

cat >isodownloader.sh<<YAML
#!/bin/bash
curl -k -L "$DOWNLOAD_URL" -o ai-install.iso
YAML
```

**Load iso on baremetal cluster**

**Press tab to edit boot config**

**Use the command below to assign name to server on boot**
```
ip=::::edge1.baremetal-testing.example.com:eno1:dhcp nameserver=192.168.1.2 
```

**For pxe deployments**
* install memdisk
* add the below to your pxefile
```

            LABEL signaliso
                MENU LABEL ^signaliso Install 4.8
                root (hd0,0)
                kernel ::boot/amd64/memdisk/memdisk
                append iso initrd=::boot/amd64/ai-install/1/ai-install.iso raw
            MENU END
```

**Once machine has booted get collect agent info**
```
export CLUSTER_DEPLOYMENT="baremetal-testing"
oc get agentclusterinstalls $CLUSTER_DEPLOYMENT-aci -o json -n assisted-installer | jq '.status.conditions[]'
```

**Get status of machine once machine has started**  
*This will return blank until the cluster has registred*
```
oc get agents.agent-install.openshift.io -n assisted-installer  -o=jsonpath='{range .items[*]}{"\n"}{.spec.clusterDeploymentName.name}{"\n"}{.status.inventory.hostname}{"\n"}{range .status.conditions[*]}{.type}{"\t"}{.message}{"\n"}{end}'
```

**Check for the clusterid**
```
oc get agents.agent-install.openshift.io -n assisted-installer
```

**Approve cluster**
```
export CLUSTER_DEPLOYMENT="baremetal-testing"
CLUSTER_ID=$(oc get agents.agent-install.openshift.io -n assisted-installer | grep ${CLUSTER_DEPLOYMENT} | awk '{print $1}')
oc -n assisted-installer patch agents.agent-install.openshift.io $CLUSTER_ID -p '{"spec":{"approved":true}}' --type merge
```

**Monitor installation**  
`You can also ssh into device using core username and the ssh key you created`
```
$ oc get agents.agent-install.openshift.io -n assisted-installer
or
$ oc get agents.agent-install.openshift.io -n assisted-installer  -o=jsonpath='{range .items[*]}{"\n"}{.spec.clusterDeploymentName.name}{"\n"}{.status.inventory.hostname}{"\n"}{range .status.conditions[*]}{.type}{"\t"}{.message}{"\n"}{end}'
or 
$ export CLUSTER_DEPLOYMENT="baremetal-testing"
$ oc get agentclusterinstalls $CLUSTER_DEPLOYMENT-aci -o json -n assisted-installer | jq '.status.conditions[]'
```

## Update DNS settings to access instance
```
api.baremetal-testing IN A 192.168.1.19
*.apps.baremetal-testing IN A 192.168.1.19
edge1.baremetal-testing      IN A 192.168.1.19
```

## Access you OpenShift instance 
```
$ export CLUSTER_DEPLOYMENT="baremetal-testing"

$ mkdir -p ${HOME}/${CLUSTER_DEPLOYMENT}/auth

$ oc get secret -n assisted-installer $CLUSTER_DEPLOYMENT-admin-kubeconfig -o json | jq -r '.data.kubeconfig' | base64 -d > ${HOME}/${CLUSTER_DEPLOYMENT}/auth/$CLUSTER_DEPLOYMENT-admin-kubeconfig

$ oc get secret -n assisted-installer $CLUSTER_DEPLOYMENT-admin-password -o json | jq -r '.data.password' | base64 -d > ${HOME}/${CLUSTER_DEPLOYMENT}/auth/$CLUSTER_DEPLOYMENT-admin-password

$ export KUBECONFIG=${HOME}/${CLUSTER_DEPLOYMENT}/auth/$CLUSTER_DEPLOYMENT-admin-kubeconfig 

$ oc get co

# oc whoami --show-console
```

## Troubleshooting
 * if a Device fails to deploy run the following to recreate an iso
```
$ kustomize build  ${CLUSTER_DEPLOYMENT}/03-deployment | oc delete -f - 
$ sleep 60s
$ kustomize build  ${CLUSTER_DEPLOYMENT}/03-deployment | oc create -f - 
$ ./scripts/assisted-service-status.sh
```

## Links: 
* [Deploy Bare-Metal Clusters with CRC](https://gist.github.com/v1k0d3n/9ceec7589b5bab0b61b85c2a1e1c463c)
* https://github.com/openshift/assisted-service/tree/master/docs
* [Release Status](https://openshift-release.apps.ci.l2s4.p1.openshiftapps.com/)