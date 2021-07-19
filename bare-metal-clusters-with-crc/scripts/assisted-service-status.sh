#!/bin/bash 

function waitforme() {
  pod=$1
  namespace=$2
  POD_NAME=$(oc get pods -n ${namespace} | grep ${pod} | awk '{print $1}')
  while [[ $(oc get pods $POD_NAME -n $namespace -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod $POD_NAME" && sleep 5; done
}

waitforme assisted-service assisted-installer 

