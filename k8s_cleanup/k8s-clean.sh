#!/bin/bash

# Define max days as 7 if not set
max=${DAYS:-7}

# Delete empty ReplicaSets older than $max days
kubectl get rs --all-namespaces -o jsonpath='{range .items[?(@.spec.replicas==0)]}{.metadata.namespace}{"|"}{.metadata.name}{"|"}{.metadata.creationTimestamp}{"\n"}{end}' | \
  awk -v max="$max" -F "|" '$3 < "'$(date -d "now - $max days" +%Y-%m-%dT%H:%M:%SZ)'" {print $1 " " $2}' | \
  xargs -I {} bash -c 'kubectl -n $0 delete rs $1' "$1" {}

# Delete finished jobs older than 1 hour
kubectl get jobs --all-namespaces -o jsonpath='{range .items[?(@.status.succeeded==1)]}{.metadata.namespace}{"|"}{.metadata.name}{"|"}{.metadata.creationTimestamp}{"\n"}{end}' | \
  awk -F "|" '$3 < "'$(date -d "now - 1 hour" +%Y-%m-%dT%H:%M:%SZ)'" {print $1 " " $2}' | \
  xargs -I {} bash -c 'kubectl -n $0 delete job $1' "$1" {}

# Delete evicted pods older than 1 hour
kubectl get pods --all-namespaces -a -o jsonpath='{range .items[?(@.status.phase=="Failed" && @.status.reason=="Evicted")]}{.metadata.namespace}{"|"}{.metadata.name}{"|"}{.metadata.creationTimestamp}{"\n"}{end}' | \
  awk -F "|" '$3 < "'$(date -d "now - 1 hour" +%Y-%m-%dT%H:%M:%SZ)'" {print $1 " " $2}' | \
  xargs -I {} bash -c 'kubectl -n $0 delete pod $1' "$1" {}
