<!--
SPDX-FileCopyrightText: 2026 Forschungszentrum Jülich GmbH
SPDX-FileContributor: Oliver Bertuch

SPDX-License-Identifier: CC-BY-4.0
-->

# DCM 2026 Kubernetes Workshop: Continuous Delivery for Dataverse on K8s: “vlûch serviert”

<small>(‘vlûch serviert’ riffs on modern German ‘flugs/fluchs serviert’ (EN: ‘served quickly’ ) - and on FluxCD.)</small>

*This is an in-person event. No recording will be available.*
*Registrations are due 2026-05-07 EoB AoE.*

## Abstract

Running Dataverse in containers is increasingly common – but production-grade delivery patterns are still emerging.
This workshop demonstrates a GitOps-based, Kubernetes-native deployment using FluxCD, Kustomize, and other tools.
It puts a spotlight on how the Dataverse project’s containerization work enables repeatable deployments, upgrades,
and configuration management — so you can operate Dataverse on K8s with confidence.

## Time and Place

- Barcelona Supercomputing Centre, Room 0-1-13
- Tuesday, 2026-05-12
- Part 1: [13:00](https://time.is/1300_12_May_2026_in_Barcelona,_Spain)-[15:00](https://time.is/1500_12_May_2026_in_Barcelona,_Spain)
- Part 2: [15:30](https://time.is/1530_12_May_2026_in_Barcelona,_Spain)-[17:00](https://time.is/1700_12_May_2026_in_Barcelona,_Spain)

## Access and Security at BSC

1. Access will be permitted between 20 and 10 minutes before the start of each meeting or workshop, in order to avoid congestion at reception.
2. Upon arrival, participants will receive their access badge and be collected at reception by their designated support assistant, who will accompany them throughout their visit.
3. Please note that once inside the building, in accordance with BSC security regulations, participants may not leave and re-enter independently.
   Any exits must be coordinated with the designated support assistant.
4. Each group must remain together at all times and will be accompanied by a designated support assistant throughout their visit.
   If there is a need to split into smaller groups, this must be coordinated in advance with the assigned assistant.

## Table Of Content

| Topic                                                              | Time  | Total |
|--------------------------------------------------------------------|-------|-------|
| Introduction to containers, images, wording, context               | 5m    | 5m    |
| Introduction to Kubernetes                                         | 15m   | 20m   |
| Exercise                                                           | 30m   | 50m   |
| Introduction to Continuous Deliver and FluxCD: concept, components | 15m   | 1h5m  |
| Exercise                                                           | 30m   | 1h35m |
| Introduction to the Time and Space Continuum Strategic Reserve     | 25m   | 2h    |
| Coffee Break                                                       | 30m   | 2h30m |
| Introduction to Dataverse on Kubernetes                            | 15m   | 2h45m |
| Exercise                                                           | 30m   | 3h15m |
| Introduction to External Secrets Operator (optional)               | (10m) | 3h25m |
| Exercise                                                           | 30m   | 3h55m |
| Outro                                                              | 5m    | 4h    |

We cannot look into automating certificates via ACME, as we don't have the necessary network access.
If you don't like YAML, you're in for a treat (</ sarcasm>).

## Learning Resources

- https://guides.dataverse.org/en/latest/container/index.html
- https://fluxcd.io/flux/

### Container Images
- https://hub.docker.com/_/postgres
- https://hub.docker.com/_/solr
- https://hub.docker.com/r/gdcc/dataverse

### K8s Tutorials
- https://kubernetes.io/docs/tutorials/kubernetes-basics/
- https://kubeasy.dev/challenges
- https://collabnix.github.io/kubelabs/

## Prepare At Home

### Hardware
Check your laptop: if you have less than 16G of RAM, or less than 4 CPUs, get a different one.
There are no other laptops or VMs around and 16G is cutting it close.
You are also welcome to run K8s on a remote host if that's easier for you, but you may run into compatibility
problems with storage and ingress definitions (these are the most tricky bits).

### Git
We will make use of Git a lot, but there will be no introduction.
If you don't have much experience or want to brush up: please prepare run through one or more Git tutorials.
We won't do anything fancy with Git – you need to know the basic workflow and its commands like `add`, `commit`, `push`, and `pull`.

If you don't have Git installed, are fine with command line use, and dislike your IDEs Git client,
please [install Git as a command line tool](https://git-scm.com/install/).

## GitHub
We will use GitHub for our exercises. Please create:
1. A Github account and let me know which that is.
2. A Github Personal Access Token for FluxCD. (Please don't send me that, it's a secret. But write it down some place secure!)

### Local Kubernetes
As we will work with Kubernetes, you need a test cluster. Please don't reuse any production clusters for experiments.
To setup a small Kubernetes on your laptop, there are multiple options:
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (GUI+VM)
- [Rancher Desktop](https://rancherdesktop.io/) (GUI+VM)
- [Colima](https://colima.run) (CLI+VM)
- [Minikube](https://minikube.sigs.k8s.io/docs/) (CLI+VM)

I recommend using *Rancher Desktop* if you have not a lot of experience.
It's open source and free for commercial use, unlike Docker Desktop.
You can follow the official [installation documentation](https://docs.rancherdesktop.io/getting-started/installation),
but there are also a plethora of tutorials in blog posts and videos on YouTube how to do that.

### Verify Setup and Pull Images
Please execute [Task 1 - Setup K8s](./task-1-setup-k8s/README.md) to make sure we don't lose too much time with setup and bandwidth problems. (Images will be cached locally unless you delete them.)

### Tooling
Please have these at the ready:
1. FluxCD client (https://fluxcd.io/flux/cmd/)
2. An editor or IDE you like. I very much encourage you to use something with good syntax highlighting for YAML.
   Here are some options: [Zed](https://zed.dev/), [IntelliJ IDEA](https://www.jetbrains.com/idea), or [VS Code](https://code.visualstudio.com/).

## Useful Links

- [OhMyZsh Kubectl Plugin for shorter aliases](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/kubectl)
