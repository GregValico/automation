#!/bin/bash

gcloud compute ssh --zone "$REGION-a" "gke-jump-$CLUSTER_NAME" --project "$PROJECT_NAME" --command "
  
  sleep 20

  export PROXY_IP='${{ env.PROXY_IP }}'
  export CLUSTER_NAME='${{ env.CLUSTER_NAME }}'
  export PROJECT_NAME='${{ env.PROJECT_NAME }}'

  echo \$PROXY_IP

  gcloud config set project \$PROJECT_NAME
"