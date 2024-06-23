#!/bin/bash

gcloud compute ssh --zone "$REGION-a" "gke-jump-$CLUSTER_NAME" --project "$PROJECT_NAME" --command "
  
  sleep 20

  echo From inside the VM, the PROXY IP is $PROXY_IP
  echo Cluster name is $CLUSTER_NAME
  echo Project name is $PROJECT_NAME

  # gcloud container clusters get-credentials ${{ inputs.cluster_name }} --region ${{ inputs.region }} --project ${{ inputs.project_name }}
"