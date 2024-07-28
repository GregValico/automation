#!/bin/bash

gcloud compute ssh --zone "$REGION-a" "gke-jump-$CLUSTER_NAME" --project "$PROJECT_NAME" --command "
  
  sleep 20

  gcloud container clusters get-credentials $CLUSTER_NAME --region $REGION --project $PROJECT_NAME

  cat <<EOF | kubectl apply -f -
  apiVersion: v1
  kind: Namespace
  metadata:
    name: api-proxy
EOF
  cat <<EOF | kubectl apply -f -
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: k8s-api-proxy
    namespace: api-proxy
    labels:
      app: k8s-api-proxy
  spec:
    replicas: 1
    selector:
      matchLabels:
        app: k8s-api-proxy
    template:
      metadata:
        labels:
          app: k8s-api-proxy
      spec:
        containers:
        - name: k8s-api-proxy
          image: maaand/k8s-api-proxy:v9
          ports:
          - containerPort: 8118
          resources:
            limits:
              cpu: 200m
              memory: 128Mi
            requests:
              cpu: 100m
              memory: 64Mi
EOF
  cat <<EOF | kubectl apply -f -
  apiVersion: v1
  kind: Service
  metadata:
    name: k8s-api-proxy
    namespace: api-proxy
    labels:
      run: k8s-api-proxy
    annotations:
      cloud.google.com/load-balancer-type: "Internal"
  spec:
    type: LoadBalancer
    loadBalancerIP: $PROXY_IP
    ports:
    - port: 8118
      protocol: TCP
      targetPort: 8118
    selector:
      app: k8s-api-proxy
EOF
  cat <<EOF | kubectl apply -f -
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: ip-masq-agent
    namespace: kube-system
  data:
    config: |-
      nonMasqueradeCIDRs:
        - $POD_RANGE
        - $SVC_RANGE
      masqLinkLocal: false
      resyncInterval: 30s
EOF
  cat <<EOF | kubectl apply -f -
  apiVersion: apps/v1
  kind: DaemonSet
  metadata:
    name: ip-masq-agent
    namespace: kube-system
  spec:
    selector:
      matchLabels:
        k8s-app: ip-masq-agent
    template:
      metadata:
        labels:
          k8s-app: ip-masq-agent
      spec:
        hostNetwork: true
        containers:
        - name: ip-masq-agent
          image: gke.gcr.io/ip-masq-agent:v2.9.3-gke.5@sha256:c75a164d6011c7da7084da0fddfc7419914025e092741c3c230cec1589a1a06b
          args:
          # The masq-chain must be IP-MASQ
          - --masq-chain=IP-MASQ
          # To non-masquerade reserved IP ranges by default,
          # uncomment the following line.
          # - --nomasq-all-reserved-ranges
          securityContext:
            privileged: false
          volumeMounts:
          - name: config-volume
            mountPath: /etc/config
        volumes:
        - name: config-volume
          configMap:
            name: ip-masq-agent
            optional: true
            items:
            - key: config
              path: ip-masq-agent
        tolerations:
        - effect: NoSchedule
          operator: Exists
        - effect: NoExecute
          operator: Exists
        - key: "CriticalAddonsOnly"
          operator: "Exists"
EOF
"