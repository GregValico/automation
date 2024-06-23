#!/bin/bash

gcloud compute ssh --zone "$REGION-a" "gke-jump-$CLUSTER_NAME" --project "$PROJECT_NAME" --command "
  
  sleep 20

  hostname
  gcloud container clusters get-credentials $CLUSTER_NAME --region $REGION --project $PROJECT_NAME

  echo From inside the VM, the PROXY IP is $PROXY_IP
  echo Cluster name is $CLUSTER_NAME
  echo Project name is $PROJECT_NAME

  cat <<EOF | kubectl apply -f -
  apiVersion: v1
  kind: Namespace
  metadata:
    name: $PROJECT_NAME
EOF


"