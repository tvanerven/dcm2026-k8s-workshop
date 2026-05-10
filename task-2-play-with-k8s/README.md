<!--
SPDX-FileCopyrightText: 2026 Forschungszentrum Jülich GmbH
SPDX-FileContributor: Oliver Bertuch

SPDX-License-Identifier: CC-BY-4.0
-->

# Task 2 - Play around with Kubernetes

Please make sure to have executed all steps from the [previous task](../task-1-setup-k8s/README.md) before going through with this task.

## Summary

## Context

## Steps
### Step 1 - Enable service exposure to your local host
If you're running Rancher Desktop on Linux, you probably have to (temporarily) declare port 80 as "non-privileged" to be able to access HTTP applications inside the cluster.

To allow Traefik to be bound to privileged ports until next reboot (you better not make this permanent), run:
```shell
sudo sysctl -w net.ipv4.ip_unprivileged_port_start=80
```
Then restart Rancher Desktop (quit and re-open).

#### Alternative with port forward
If you don't want to do this or need an alternative if you're not using Rancher Desktop, create a port forwarding in a separate shell:

```shell
kubectl port-forward -n kube-system service/traefik 8080:80
```

This will expose the Traefik Ingress Controller port 80 in the VM on port 8080 on your laptop.

#### Alternative if running on host with routable, external IP
If you run all of this on a machine that is exposed to the internet and you can access the services over the web, you might not have DNS set up for it.

Here's a neat trick to temporarily resolve an FQDN without modifying /etc/hosts.
```shell    
curl --resolve <FQDN>:80:<External IP of your Ingress> http://<FQDN>/...
```

### Step 2 - Deploy a stateless "whoami" application

1. Deploy to the cluster: `kubectl apply -f step-2/whoami.yaml`
2. Access the service on your host's terminal: `curl http://whoami.ct.gdcc.io`

### Step 3 - Familiarize with basic kubectl commands

Please run the following commands on after another and try to understand the output of each. (The first one can be ignored.)

```shell
kubectl config set-context --namespace whoami --current
kubectl get service
kubectl describe service whoami
kubectl get deployment
kubectl describe deployment whoami
kubectl get pod
kubectl describe pod whoami-xxxxxxxxxx-xxxxx
kubectl get ingress
kubectl describe ingress whoami
```

### Step 4 - Deploy an application with attached storage

1. Deploy to cluster: `kubectl apply -f step-4/washere.yaml`
2. Access the service: `curl http://washere.ct.gdcc.io -A i-was-here`

### Step 5 - Analyse the logs

Watch for `i-was-here` in the access logs: 

```shell
kubectl config set-context --namespace washere --current
kubectl get pod
kubectl logs washere-xxxxxxxxxx-xxxxx
```

### Step 6 - Understand storage organisation

Now try to understand the volume management. What's the difference between a "Physical Volume" and a "Physical Volume Claim"?

```shell
kubectl get pvc
kubectl describe physicalvolumeclaim washere-volume
kubectl describe physicalvolume pvc-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxxx
```

## Next Task
After the next round of slides, we'll continue with [Task 3](../task-3-kustomize/README.md). 
