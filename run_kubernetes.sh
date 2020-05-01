#!/usr/bin/env bash

# This tags and uploads an image to Docker Hub

# Step 1:
# This is your Docker ID/path
# dockerpath=<>
dockerpath=dantesaggin/development
appname=prediction-microservice

# Step 2
# Run the Docker Hub container with kubernetes
kubectl create -f deployment-pod.yaml


# Step 3:
# List kubernetes pods
kubectl get pods
while [[ $(kubectl get pods -l app=$appname -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
  echo "waiting for pod" && sleep 1;
  kubectl get pods;
done

# Step 4:
# Forward the container port to a host

kubectl create -f loadbalancer.yaml
external_ip=""
while [ -z $external_ip ]; do
  echo "Waiting for end point..."
  external_ip=$(kubectl get svc $appname --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
  [ -z "$external_ip" ] && sleep 10
done
echo 'End point ready:' && echo $external_ip