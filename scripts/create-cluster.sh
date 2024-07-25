#!/bin/bash

gcloud config set project $PROJECT_NAME

gcloud beta container --project "$PROJECT_NAME" clusters create "$CLUSTER_NAME" \
    --region "$REGION" \
    --no-enable-basic-auth \
    --cluster-version "1.29.6-gke.1038001" \
    --release-channel "regular" \
    --machine-type "$MACHINE_TYPE" \
    --image-type "COS_CONTAINERD" \
    --disk-type "pd-balanced" \
    --disk-size "50" \
    --metadata disable-legacy-endpoints=true \
    --scopes "https://www.googleapis.com/auth/cloud-platform" \
    --max-pods-per-node "30" \
    --num-nodes "1" \
    --logging=SYSTEM,WORKLOAD \
    --monitoring=SYSTEM \
    --enable-private-nodes \
    --enable-private-endpoint \
    --private-endpoint-subnetwork="projects/$PROJECT_NAME/regions/$REGION/subnetworks/$SUBNET" \
    --enable-ip-alias \
    --network "projects/$PROJECT_NAME/global/networks/$VPC_NAME" \
    --subnetwork "projects/$PROJECT_NAME/regions/$REGION/subnetworks/$SUBNET" \
    --cluster-secondary-range-name "$POD_RANGE_NAME" \
    --services-secondary-range-name "$SVC_RANGE_NAME" \
    --no-enable-intra-node-visibility \
    --default-max-pods-per-node "30" \
    --enable-autoscaling --min-nodes "0" --max-nodes "1" \
    --location-policy "BALANCED" \
    --security-posture=standard \
    --workload-vulnerability-scanning=disabled \
    --enable-master-authorized-networks \
    --addons HorizontalPodAutoscaling,GcePersistentDiskCsiDriver \
    --enable-autoupgrade \
    --enable-autorepair \
    --max-surge-upgrade 1 \
    --max-unavailable-upgrade 0 \
    --maintenance-window-start "2024-06-16T06:00:00Z" \
    --maintenance-window-end "2024-06-16T11:00:00Z" \
    --maintenance-window-recurrence "FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR,SA,SU" \
    --binauthz-evaluation-mode=DISABLED \
    --enable-managed-prometheus \
    --workload-pool "$PROJECT_NAME.svc.id.goog" \
    --enable-shielded-nodes \
    --verbosity=info
