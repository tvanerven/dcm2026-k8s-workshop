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

----
# Dataverse Containers
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
   <small>Exception: `docker exec curl` inside running container.</small>
2. Logs not written to `server.log` but stdout, use `docker logs`.
3. "JVM Options": most, but not all use Microprofile Config (yet).  
   <small>(Storage not enabled, use JVM_ARGS!)</small>
4. Inject secrets via mounted file or environment variable.  
   <small>`/secrets` is your friend</small>
5. Overlayfs is slow - back any place the app writes to with a volume.  
   <small>See also image docs for these locations!</small>
6. Think ephemeral - ideally you don't change the image's content!
7. Add container limits for RAM; 70% default Heap. Tunable using env vars.

----

# Dataverse in Containers III
### A simple example

![](https://plantuml.online/png/PP5HJuCm58NV-HLr3mQJ3JGpY_BcjWTZPe9ZUoQ5LjPOsgOjKsByxzwMWSEHa9HxltFkxU6AYP8tXAA3jSeaSQpnPrGnUsYAnb1TIc6fi54fwrXnB6nJyvcnXBCYNjtFKbVQlsxY6XjBDPJo5IWm4rH72jWWIAasKeGbP-0pHPELFqnkWgm5IPqlPIC8rcreMfEJ8n1hRF4HL1IjgUAohJsFlWC4ps0VOgNEuGbyFBbIYbkiyHIzu2D6rsWd9JUkMP6oZ4cF9ujeCHEou1HM6HkJ0kXK6bjfchrjdDQzggkOv6vn8M62q2zWCibrpniu9u_HGtHxWKEgxwnoOVZ34d_GGURNx832rKUB_fnI2ytSJPkZp4gDAzSAjfJdso7dBfszeVxkpxjT6cT0ZQ5XZoveysVZvJw8tcB91FmbfBIqifJyvBNfoFx-v_E6QPxm2_zhk_wGHRTm5qYZHzml)

---

# Dataverse in Kubernetes

    ![](https://plantuml.online/png/ZP9TJuCm58Rl-HN8rPOuqCGioYNRXJ5Rd6DwIqevOsXfc_PqIep_tK83MVPXvAezx_EUht9LSSfC0VuEKUeuYXJv3CiAToOt6XGL785ZI4KTIKOucffDD1QiogFPtMJLXbwNYwWc6a7PK3Qp3b9nKA6qhEUbZLNgB1665qGr8ztehDXV-y6S8Dc3qk3FGJBHrBPECFQ_FTz-GvOHaV8G3kmbHOAmDIm5RAzbGMbKz40y3QSJBd86mVWeLP5RUYKqbWhIbyMPLDA9EhwTdhWhNi1NQn5CdR5g6uuVmllmviHfbxYjIilCkaD2Fg3By2JoeN_7vAtqnmJl-rf8RArlI_zPOYMu3eR4IoBFpEmCy-H_l0RQpWPK0NQeErhkn_FMmDnxT9jyrT0HISNjm_fI2HHKC8iENB-p7dtSR5PEpzQE62QoBMXJMsnyMEQovXezK3gfNxNxQzoOHXqN7x1BrNlzGWEzVDB3Bm00)

---

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

</div><div>

### Dataverse
- StatefulSet
- multiple PVC
- Service
- Secrets
- ConfigMap (JVM Opts)

</div><div>

### ConfigBaker
- 2xJobs (Bootstrap, DB Opts)
- Secrets
- 3x ConfigMap (JVM Opts, DB Opts, Bootstrap Script)

</div>
</grid>

---

# Task (1h)

Let's build this together, step by step.

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
