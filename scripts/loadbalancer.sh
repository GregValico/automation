#!/bin/bash

gcloud compute ssh --zone "$REGION-a" "gke-jump-$CLUSTER_NAME" --project "$PROJECT_NAME" --command "
  
  sleep 20

  echo $PROXY_IP
"