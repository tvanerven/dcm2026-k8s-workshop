---
title: Dataverse, Containers, Kubernetes
theme: https://apps.fz-juelich.de/fdm/reveal/fzj.css
revealOptions:
  totalTime: 7200
  transition: slide
---

<!-- .slide: data-timing="0" -->

# Continuous Delivery for Dataverse on K8s
## “vlûch serviert” - Session 2

&nbsp;  

![](img/dataverse.svg) <!-- .element: style="height: 2em; vertical-align: middle" --> Dataverse Community Meeting 2026

2026-05-12 | Oliver Bertuch <!-- .element: class="date-name" -->

---
# Logistics

### Session 2 :: 15:30 - 17:00
Deploy Dataverse, play around, possibly External Secrets

### Facilities
🤷

---
# Session II

TODO: pictures & agenda

---
# Dataverse in Containers
### Our images

Community and IQSS supported images for the latest three releases plus `develop`.

Tags follow the [Bitnami pattern](https://docs.vmware.com/en/VMware-Tanzu-Application-Catalog/services/tutorials/GUID-understand-rolling-tags-containers-index.html).  
(`c` = current minor release):
  - *Rolling*:  
    `unstable` = `6.(c+1)-flavor`,  
    `latest` = `6.c-flavor, 6.(c-1)-flavor, 6.(c-2)-flavor`
  - *Fixed*:  
    `6.c-flavor-rX`, `6.(c-1)-flavor-rX`, `6.(c-2)-flavor-rX`

----
# Dataverse in Containers II
### Most important differences to classic installations

1. Any HTTP contact to Admin API: needs "unblock-key" policy!  
   <small>Exception: `kubectl exec -it curl` inside running container.</small>
2. Logs not written to `server.log` but stdout, use `kubectl logs`.
3. "JVM Options": most, but not all use Microprofile Config (yet).  
   <small>(Storage not enabled, use JVM_ARGS!)</small>
4. Secrets consumed by MPCONFIG: use mounted file or env. variable.  
   <small>`/secrets` is your friend in Kubernetes!</small>
5. Back any place Dataverse writes to with a volume mount.  
   <small>See also image docs for these locations!</small>
6. Think ephemeral - you can't change the image content as non-root!
7. Add container limits for CPU and RAM (default: uses 70% as heap)

----
# Dataverse in Containers III
### A simple example

![](https://plantuml.online/png/PP5HJuCm58NV-HLr3mQJ3JGpY_BcjWTZPe9ZUoQ5LjPOsgOjKsByxzwMWSEHa9HxltFkxU6AYP8tXAA3jSeaSQpnPrGnUsYAnb1TIc6fi54fwrXnB6nJyvcnXBCYNjtFKbVQlsxY6XjBDPJo5IWm4rH72jWWIAasKeGbP-0pHPELFqnkWgm5IPqlPIC8rcreMfEJ8n1hRF4HL1IjgUAohJsFlWC4ps0VOgNEuGbyFBbIYbkiyHIzu2D6rsWd9JUkMP6oZ4cF9ujeCHEou1HM6HkJ0kXK6bjfchrjdDQzggkOv6vn8M62q2zWCibrpniu9u_HGtHxWKEgxwnoOVZ34d_GGURNx832rKUB_fnI2ytSJPkZp4gDAzSAjfJdso7dBfszeVxkpxjT6cT0ZQ5XZoveysVZvJw8tcB91FmbfBIqifJyvBNfoFx-v_E6QPxm2_zhk_wGHRTm5qYZHzml)

---
# Dataverse in Kubernetes

![](https://plantuml.online/png/ZP9TJuCm58Rl-HN8rPOuqCGioYNRXJ5Rd6DwIqevOsXfc_PqIep_tK83MVPXvAezx_EUht9LSSfC0VuEKUeuYXJv3CiAToOt6XGL785ZI4KTIKOucffDD1QiogFPtMJLXbwNYwWc6a7PK3Qp3b9nKA6qhEUbZLNgB1665qGr8ztehDXV-y6S8Dc3qk3FGJBHrBPECFQ_FTz-GvOHaV8G3kmbHOAmDIm5RAzbGMbKz40y3QSJBd86mVWeLP5RUYKqbWhIbyMPLDA9EhwTdhWhNi1NQn5CdR5g6uuVmllmviHfbxYjIilCkaD2Fg3By2JoeN_7vAtqnmJl-rf8RArlI_zPOYMu3eR4IoBFpEmCy-H_l0RQpWPK0NQeErhkn_FMmDnxT9jyrT0HISNjm_fI2HHKC8iENB-p7dtSR5PEpzQE62QoBMXJMsnyMEQovXezK3gfNxNxQzoOHXqN7x1BrNlzGWEzVDB3Bm00)

----
# Dataverse in Kubernetes
### What we'll need

<grid>
<div>

### PostgreSQL
- StatefulSet
- PhysicalVolumeClaim
- Service
- DB Secret

</div><div>

### Solr
- StatefulSet
- PhysicalVolumeClaim
- Service
- Init Container for Core Config
- Solr Driver Sidecar

</div><div>

### Dataverse
- StatefulSet
- multiple PVCs
- Service
- Secrets
- ConfigMap (JVM Opts)

</div><div>

### ConfigBaker
- 2xJobs (Bootstrap, DB Opts)
- Secrets
- ConfigMaps (DB Opts)

</div>
</grid>

----
# Dependency: PostgreSQL
### Where to get it
Most used is `docker.io/library/postgres` (a.k.a. `postgres`)

Bitnami is no longer an option w/o deep pockets.

Some specialized images around.

### How to deploy
Use an Operator for clustered HA / performance approach.

Since Bitnami died, no go-to Helmchart exists.
[CloudPirates try to continue where Bitnami dropped the ball.](TODO)

Use a simplistic approach using Kustomize.
(Which is what we'll do as our exercise.)

----
# Dependency: Solr
### Where to get it
Most used is `docker.io/library/solr` (a.k.a. `solr`)

Bitnami is no longer an option w/o deep pockets.

[Related Containerization Working Group discussion to have our own.](TODO)

### How to deploy
High availability and performance only via SolrCloud.
An OSS Operator exists. Dataverse does not support it (yet?).  
<small>Yes, there is user managed HA. PITA to get right.</small>

Bitnami Helmchart for standalone no longer an option.
To date, no bigger efforts for replacement.

We'll go with Kustomize for the exercise ("good enough").



----
# Apply Job

What it does
Explain the hash trick

----
# Bootstrap Job

What it does
Explain the one-off thing


---



---
# Additional resources
### Solr Driver
Automate Solr schema updates
### Branding and Static Assets
Route via Ingress to HTTP server (nginx or other) to serve static images, CSS, etc
### Fight Bots
Deploy Anubis as intermediate request authorizer


---
<!-- .slide: data-timing="0" -->
# Thank you for your attention!

<grid>

<div>

  ### $ whoami
  ![](img/bertuch-informal.jpg) <!-- .element: style="height: 7vh; border-radius: 50%; margin: 0;" -->  
  Oliver Bertuch  
  [Central Library, FZJ, Germany](https://go.fzj.de/zb)

</div><div>

  ### $ reachout
  <i class="far fa-envelope"></i> o.bertuch@fz-juelich.de  
  <i class="fab fa-github"></i> [@poikilotherm](https://github.com/poikilotherm)

</div><div>

  ### $ ls /workplaces
  [FZJ RDM](https://www.fz-juelich.de/en/zb/open-science/research-data-management)  
  <i class="fas fa-plus"></i>
  [Dataverse Core Team Member](https://dataverse.org/about)

</div><div>

  ### $ attribution
  Slides licensed under [![](img/cc-by-nd.png)<!-- .element: style="max-height: 1.6rem;" -->](https://creativecommons.org/licenses/by-nd/4.0/),  
  Icons by [Font Awesome](https://fontawesome.com/license)  
  All images CC-BY  
  Logos are non-CC material

</div>

</grid>
