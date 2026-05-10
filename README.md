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

### Homework before the workshop

- [Task 0 - Preparations](./task-0-prepare/README.md)
- [Task 1 - Setup Local Kubernetes](./task-1-setup-k8s/README.md)

### Lessons

| Topic                                                              | Time  | Total |
|--------------------------------------------------------------------|-------|-------|
| Introduction to containers, images, wording, context               | 5m    | 5m    |
| Introduction to Kubernetes                                         | 15m   | 20m   |
| Exercise                                                           | 30m   | 50m   |
| Introduction to Kustomize                                          | 5m    | 55m   |
| Exercise                                                           | 15m   | 1h10m |
| Introduction to Continuous Deliver and FluxCD: concept, components | 15m   | 1h20m |
| Exercise                                                           | 30m   | 1h50m |
| Strategic Time and Space Continuum Reserve                         | 10m   | 2h    |
| Coffee Break                                                       | 30m   | 2h30m |
| Introduction to Dataverse on Kubernetes                            | 15m   | 2h45m |
| Exercise                                                           | 30m   | 3h15m |
| Introduction to External Secrets Operator (optional)               | (10m) | 3h25m |
| Exercise                                                           | 30m   | 3h55m |
| Outro                                                              | 5m    | 4h    |

We cannot look into automating certificates via ACME, as we don't have the necessary network access.
If you don't like YAML, you're in for a treat (</ sarcasm>).

## Learning Resources

- [Shared Notepad](https://iffmd.fz-juelich.de/YF72GdtgRWmfjeQp9Y4ppQ?both)
- [Container Guide](https://guides.dataverse.org/en/latest/container/index.html)
- [Flux Docs](https://fluxcd.io/flux/)

### Container Images
- https://hub.docker.com/_/postgres
- https://hub.docker.com/_/solr
- https://hub.docker.com/r/gdcc/dataverse

### K8s Tutorials
- https://kubernetes.io/docs/tutorials/kubernetes-basics/
- https://kubeasy.dev/challenges
- https://collabnix.github.io/kubelabs/

## Useful Links

- [OhMyZsh Kubectl Plugin for shorter aliases](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/kubectl)
