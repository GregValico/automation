#!/bin/bash

gcloud compute instances create gke-jump-$CLUSTER_NAME \
    --project=$PROJECT_NAME \
    --zone=$REGION-a \
    --machine-type=e2-medium \
    --network-interface=network-tier=PREMIUM,nic-type=VIRTIO_NET,stack-type=IPV4_ONLY,subnet=$SUBNET \
    --metadata=enable-oslogin=true \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --service-account=$GCP_SA \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --tags=http-server,https-server \
    --create-disk=auto-delete=yes,boot=yes,device-name=gke-jump,image=projects/debian-cloud/global/images/debian-12-bookworm-v20240617,mode=rw,size=10,type=projects/$PROJECT_NAME/zones/$REGION-a/diskTypes/pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=goog-ec-src=vm_add-gcloud \
    --reservation-affinity=any