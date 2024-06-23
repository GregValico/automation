#!/bin/bash

gcloud compute ssh --zone "$REGION-a" "gke-jump-$CLUSTER_NAME" --project "$PROJECT_NAME" --command '
  
  sleep 20

  export PROXY_IP="${PROXY_IP}

  echo The api proxy IP is $PROXY_IP

  gcloud config set project $PROJECT_NAME
  gcloud container clusters get-credentials $CLUSTER_NAME --region=$REGION --project=$PROJECT_NAME
  
  cat <<EOF | kubectl apply -f -
  apiVersion: v1
  kind: Namespace
  metadata:
    name: test
EOF
  cat <<EOF | kubectl apply -f -
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: nginx-deployment
    namespace: test
    labels:
      app: nginx
  spec:
    replicas: 3
    selector:
      matchLabels:
        app: nginx
    template:
      metadata:
        labels:
          app: nginx
      spec:
        containers:
        - name: nginx
          image: nginx:latest
          ports:
          - containerPort: 80
EOF
  cat <<EOF | kubectl apply -f -
  apiVersion: v1
  kind: Service
  metadata:
    name: nginx-service
    namespace: test
    labels:
      app: nginx
    annotations:
      cloud.google.com/load-balancer-type: "Internal"
  spec:
    type: LoadBalancer
    loadBalancerIP: $PROXY_IP
    ports:
    - port: 80
      targetPort: 80
    selector:
      app: nginx
EOF
'