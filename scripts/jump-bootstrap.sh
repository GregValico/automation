#!/bin/bash

gcloud compute ssh --zone "$REGION-a" "gke-jump-$CLUSTER_NAME" --project "$PROJECT_NAME" --command '
  sleep 20
  sudo apt-get update
  sudo apt-get install -y apt-transport-https ca-certificates gnupg curl
  curl -sSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

  # Add the Google Cloud SDK repository
  echo "deb https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list

  # Update package list and install Google Cloud SDK, kubectl, and GKE auth plugin
  sudo apt-get update
  sudo apt-get install -y google-cloud-sdk google-cloud-sdk-gke-gcloud-auth-plugin kubectl
'