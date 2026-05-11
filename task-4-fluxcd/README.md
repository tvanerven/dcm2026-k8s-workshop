<!--
SPDX-FileCopyrightText: 2026 Forschungszentrum Jülich GmbH
SPDX-FileContributor: Oliver Bertuch

SPDX-License-Identifier: CC-BY-4.0
-->

# Task 4 — Continuous Delivery with FluxCD

Please make sure to have completed [Task 3](../task-3-kustomize/README.md) before starting.

## Summary

We'll bootstrap **FluxCD** into your local cluster and have it deploy the `washere` app from a Git repository you own.
Once that loop closes, you'll add a `whoami` app the same way — by **pushing to Git**, not by running `kubectl apply`.

Along the way you will meet two core Flux CRs:
- `GitRepository`: *where* to fetch from,
- `Kustomization`: *what* to render & apply (Flux's wrapper around `kubectl kustomize`),

In addition, we will see in addition:
- `Secret` `github-pat`: credentials to access the Git repo,
- `flux-system` namespace: an opinionated space to live for the FluxCD controllers themselves.

> ⚠️ Heads up: this is a **manual bootstrap**. The Flux docs usually recommend `flux bootstrap github`,
> which automates almost everything below. We're doing it by hand so you can *see* the moving parts.
> Maybe skip to `flux bootstrap` in real life.

## Context

You now have Kustomize overlays that render correctly with `kubectl kustomize`.
In this task, an in-cluster **controller** (`kustomize-controller`) will do exactly what you've been doing manually:
pull the latest commit from Git, render the overlay, diff against the cluster, and apply.

## Steps
### Step 0 - Prerequisites

You installed `flux` back in [Task 0](../task-0-prepare/README.md). Time to put it to use! Please run:

```shell
flux --version       # should print v2.x.x (see Task 0 if missing)
flux check --pre     # Flux's pre-flight check
```

If `flux check --pre` complains, fix that first.

### Step 1 - Clean up from earlier tasks

The `washere*` and `whoami` namespaces may have PVCs that take a moment to release.

```shell
kubectl config set-context --current --namespace=default
kubectl delete namespace whoami washere washere-dev washere-prod --wait=false --ignore-not-found

# If anything is still hanging after ~1 min, force-release stuck PVs:
kubectl get pv | awk '/Released|Failed/ {print $1}' | xargs -r \
  kubectl patch pv --type=merge -p '{"metadata":{"finalizers":null}}'
```

Wait until `kubectl get ns` shows none of the above.

### Step 2 - Create your own GitOps repository

1. Create a **new GitHub repository**. Name it whatever you like (e.g. `dcm26-gitops`).
    - Easiest path: **public**, empty (no README). Skip the PAT bits below.
    - If you must make it **private**, you'll need a Personal Access Token (details in Step 3).
2. Set two shell variables so the rest of the task copies cleanly:
   ```shell
   export WORKSHOP=~/path/to/dcm2026-k8s-workshop
   export GITOPS=~/path/to/dcm26-gitops
   ```
3. Clone it locally — somewhere *outside* the workshop checkout:
   ```shell
   git clone https://github.com/<you>/dcm26-gitops.git "$GITOPS"
   cd "$GITOPS"
   ```
4. Copy the starter content from the workshop into your new repo:
   ```shell
   cp -R "$WORKSHOP/task-4-fluxcd/clusters" .
   cp -R "$WORKSHOP/task-4-fluxcd/infrastructure" .
   ```
5. Open `clusters/test/flux-sync.yaml` and edit the `GitRepository.spec.url` to point at *your* repo:
   ```yaml
   url: https://github.com/<you>/dcm26-gitops.git
   ```
   If your repo is **private**, uncomment the `secretRef:` block from the `GitRepository`.
6. Commit and push everything:
   ```shell
   git add clusters infrastructure
   git status                          # double-check: NO flux-secret.yaml in the list
   git commit -m "Initial GitOps layout"
   git push
   ```

### Step 3 - (Private repo only) Create a GitHub Personal Access Token and edit Secret

Skip this step if your repo is public.
You should already have created a PAT in [Task 0](../task-0-prepare/README.md), but in case you missed it:

1. GitHub → Settings → Developer settings → **Personal access tokens** → *Fine-grained tokens* → *Generate new token*.
2. **Repository access**: only your new repo.
3. **Repository permissions** → **Contents**: *Read-only*. (Flux only needs to read.)
4. Copy the token. You'll paste it in the next step.

Classic PATs also work; they need the `repo` scope.

Back in `$WORKSHOP/task-4-fluxcd/flux-secret.yaml`, edit the necessary secret and add the PAT to `password`:
```yaml
# Replace this with your actual GitHub Personal Access Token
password: supersecret123
```

### Step 4 — Bootstrap Flux manually

Run:
```shell
kubectl apply -k "$GITOPS/clusters/test"                          # Installs controllers + GitRepository + Kustomizations
kubectl apply -f "$WORKSHOP/task-4-fluxcd/flux-secret.yaml"       # Private repo only; skip for public
```

Verify:
```shell
flux check                                              # all controllers healthy?
kubectl -n flux-system get pods                         # 5 pods, all Running
flux get sources git                                    # GitRepository "flux-system" should become Ready
flux get kustomizations                                 # "flux-system" and "infrastructure" should become Ready
```

If `flux get sources git` shows `Ready=False`, some common causes are:
- URL typo in `flux-sync.yaml`,
- PAT missing the `Contents: Read` permission,
- Secret in the wrong namespace or with the wrong name (must be `flux-system/github-pat`).

> 💡 You can watch events live in another terminal:
> ```shell
> flux events --watch
> ```

### Step 5 — Observe Flux deploying `washere`

The `infrastructure` FluxCD Kustomization points at `./infrastructure/test`.
The reference to the `washere` overlay is commented out in `./infrastructure/test/kustomization.yaml`.
Once Flux is bootstrapped, re-include `washere` by uncommenting, committing, and pushing:

```yaml
resources:
  - washere   # <- now uncommented
```

Then run:
```shell
cd "$GITOPS"
git add infrastructure/test/kustomization.yaml
git commit -m "Adding washere app to test infrastructure"
git push
```

Monitor FluxCD deploying for you:

```shell
kubectl -n hello-flux get all
curl -A i-was-here http://washere.ct.gdcc.io           # See the same output as in Task 3
flux tree kustomization infrastructure                 # Nice tree view of everything Flux manages
```

Note what you *didn't* do: there's no `kubectl apply -k` for `washere` anywhere in this step. Git pushed it.

### Step 6 — Change a value and watch reconciliation

Edit `infrastructure/base/washere/create-indexfile.sh` and add a line:

```sh
echo "Hello from FluxCD!" | tee -a index.html
```

Commit and push:

```shell
git add infrastructure/base/washere/create-indexfile.sh
git commit -m "Add greeting from Flux"
git push
```

Flux polls every minute by default. To not wait:

```shell
flux reconcile kustomization infrastructure --with-source
```

Then verify the rollout happened (new ConfigMap hash, updated deployment, new pod):

```shell
kubectl -n hello-flux get pods                          # one pod should be Terminating, a new one Running
kubectl -n hello-flux get cm | grep create-indexfile    # hash suffix changed
```

Once the pod is ready (it might take a second to schedule the pod, create the PV, etc), request the endpoint:
```shell
curl http://washere.ct.gdcc.io -A flux-was-here
```
The output should show the message you just added.


### Step 7 — Add `whoami` to GitOps

Now do for `whoami` what we already did for `washere`.
Recreate the overlay structure under `infrastructure/base/whoami/` (same shape as the `washere` base — `k8s/` folder, `kustomization.yml`, etc.),
and an environment overlay under `infrastructure/test/whoami/` (its own `namespace.yml` and `kustomization.yml`).

> ⚠️ **Namespace gotcha.** If a `whoami` namespace from [Task 2](../task-2-play-with-k8s/README.md) is still around 
> (check with `kubectl get ns`), either delete it now or **pick a different name** for the overlay (e.g. `hello-whoami`).
> (You either skipped the cleanup or it didn't work.) Flux uses server-side apply and tracks per-field ownership:
> when it encounters a pre-existing `Namespace` that wasn't created by Flux, it will refuse to fully manage it, and
> you'll see your `infrastructure` Kustomization stuck at `Ready=False` with an ownership / immutable-field error.
> Fresh resources Flux creates itself are always cleanly owned.

1. Build the base from the original `whoami` manifests of [Task 2](../task-2-play-with-k8s/step-2/whoami.yaml). 
   Strip selectors, drop the inline namespace, let the overlay add them - exactly like `washere` in Task 3.
2. Add an overlay at `infrastructure/test/whoami/` with its own namespace (e.g. `hello-whoami`) and Ingress host `whoami.ct.gdcc.io`.
3. Wire it into the environment by editing `infrastructure/test/kustomization.yaml`:
   ```yaml
   resources:
     - washere
     - whoami      # ← new

   ```
4. Commit and push:
   ```shell
   git add infrastructure
   git commit -m "Deploy whoami via Flux"
   git push
   flux reconcile kustomization infrastructure --with-source
   ```
5. Verify:
   ```shell
   flux tree kustomization infrastructure
   kubectl -n hello-whoami get all
   curl http://whoami.ct.gdcc.io
   ```

### Step 8 — Inspect what Flux is doing

```shell
flux get sources git                                    # GitRepository status
flux get kustomizations                                 # all Kustomizations
flux events --watch                                     # live event stream
flux logs --follow --level=error                        # controller logs (all controllers)
kubectl -n flux-system logs deploy/kustomize-controller # logs of one specific controller
kubectl -n flux-system get gitrepositories,kustomizations,helmreleases   # they're just K8s objects
```

> 🧠 Everything Flux does is itself a Kubernetes resource. `kubectl get` works on all of it. Flux is, in the end, a set of controllers that reconcile YAML.

### Step 9 — (Optional) Break something on purpose

While you have time, try these - each demonstrates a *different* Flux mechanism:

- **Drift correction.** Hand-edit the running `washere` Deployment:
  `kubectl -n hello-flux edit deploy/washere`, change `replicas: 1` → `replicas: 5`, save.
  Wait a minute (or `flux reconcile kustomization infrastructure`). Watch Flux set it back to 1.
  *Why?* Flux declares `spec.replicas` in the rendered manifest and uses server-side apply, so it re-claims that field on each reconciliation.

- **Deletion recovery.** Delete the `washere` Service: `kubectl -n hello-flux delete svc washere`.
  Flux re-creates it from Git on the next reconciliation.

- **Pruning.** Comment out `- washere` in `infrastructure/test/kustomization.yaml`, commit, push.
  Watch Flux **prune** the namespace and everything inside it.
  (`prune: true` on the Kustomization is doing the work.)

- **Ownership boundary.** Add an annotation manually:
  `kubectl -n hello-flux annotate deploy/washere experiment=true`.
  Reconcile. Flux leaves it alone — server-side apply tracks field ownership per manager,
  and Flux only re-claims fields it actually declares.
  This is why omitting `spec.replicas` from your manifests is the standard trick for
  letting an HPA scale freely without fighting Flux.

> 💡 Need to make a temporary change without Flux interfering at all?
> `flux suspend kustomization infrastructure` pauses reconciliation; `flux resume` re-enables it.

## Cleanup

Leave everything running — we'll use this cluster for Dataverse next. To tear down later:

```shell
kubectl delete -k clusters/test                         # removes the Flux controllers and Kustomizations
kubectl delete ns hello-flux hello-whoami --wait=false  # apps Flux deployed for you
```

## Next Task
After the slides, we'll continue with [Task 5 — Dataverse on Kubernetes](../task-5-dataverse/README.md).
