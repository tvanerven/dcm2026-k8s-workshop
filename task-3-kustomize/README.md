<!--
SPDX-FileCopyrightText: 2026 Forschungszentrum Jülich GmbH
SPDX-FileContributor: Oliver Bertuch

SPDX-License-Identifier: CC-BY-4.0
-->

# Task 3 — Kustomize without the magic

Please make sure to have completed [Task 2](../task-2-play-with-k8s/README.md) before starting.

## Summary

We'll take the `washere` app you just deployed and refactor it into a Kustomize **base** with two **overlays** (`dev`, `prod`).
Along the way you'll meet three Kustomize features that pull their weight in real life:

- splitting a monolithic manifest into reusable resources,
- generating a `ConfigMap` from a real file on disk (`configMapGenerator`),
- stamping a per-environment namespace and labels across every resource using the modern `labels:` transformer.

No Continuous Delivery yet — everything here renders locally with `kubectl kustomize`.

## Context

Kustomize is a YAML-on-YAML overlay tool built into `kubectl`.
There is no templating language; you describe a *base* once, and *overlays* declare patches on top.
Flux's `kind: Kustomization` (which you'll meet in Task 4) is just an in-cluster wrapper that runs the same rendering against a Git folder.

## Steps

### Step 0 — Clean up from Task 2

```shell
kubectl delete namespace washere --wait=false
```

We'll redeploy via Kustomize in this task.

### Step 1 — Inspect the base

Have a look at `student/base/`. The original `washere.yaml` has been split:  
<small>(You don't need to do the splitting yourself, it's already done; just read it.)</small>

- one file per Kubernetes resource,
- the inline `ConfigMap` is **gone** — the script lives next to the kustomization file as `create-indexfile.sh`, and is generated into a `ConfigMap` by `configMapGenerator`,
- the `Namespace` object is **not in `base/`** — each overlay owns its own namespace (and its own Pod Security settings),
- `app: washere` labels and the `selector` / `template.metadata` blocks have been **emptied** -
  the overlay's label transformer will fill them in (look for the `# kustomize!` markers).

Render the base on its own to see what's missing:

```shell
kubectl kustomize student/base
```

Things to spot in the output:

- a `ConfigMap` named like `create-indexfile-7d4f9c2b` (the suffix is a hash of the script's contents),
- the Deployment's `volumes[].configMap.name` was **rewritten** to that hashed name. ✨
- nothing has a namespace yet, and nothing has any `app:` labels.

### Step 2 — Write the `dev` overlay

Create `student/overlays/dev/`:

1. a `namespace.yaml` declaring the `washere-dev` Namespace (with the Pod Security labels — copy them from the old `washere.yaml`),
2. a `kustomization.yaml` that pulls in the base, includes the namespace file, sets the `namespace:` transformer, adds `labels:`, and patches the Ingress hostname.

Skeleton for `kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: washere-dev

resources:
  - ../../base
  - namespace.yaml

labels:
  - pairs:
      app: washere
      env: dev
    includeSelectors: true    # ← also writes the Deployment selector + Service selector

patches:
  - target: { kind: Ingress, name: washere }
    patch: |
      - op: replace
        path: /spec/rules/0/host
        value: washere-dev.ct.gdcc.io
```

> ℹ️ The namespace name appears in two places: as the `Namespace` object's `metadata.name`, and in the `namespace:` transformer.
> They must match. The transformer only rewrites `metadata.namespace` on other resources — it doesn't touch the `Namespace` object's own name.

Render and inspect:

```shell
kubectl kustomize student/overlays/dev | less
```

Things to look for in the output:

- every resource now lives in namespace `washere-dev`,
- the Service's `spec.selector` is now `{ app: washere, env: dev }` — that's how it'll find the Pods,
- the Deployment's `spec.selector.matchLabels` and `spec.template.metadata.labels` both got populated,
- the `ConfigMap` name has a hash suffix like `create-indexfile-7d4f9c2b`,
- the Deployment's `volumes[].configMap.name` was **rewritten** to match that hashed name. ✨
- the Ingress' hostname is set to `washere-dev.ct.gdcc.io`.

### Step 3 — Apply it

```shell
kubectl apply -k student/overlays/dev
kubectl config set-context --namespace washere-dev --current
kubectl get all
curl -A i-was-here http://washere-dev.ct.gdcc.io
kubectl logs deploy/washere
```

> 💡 If `curl` can't resolve the host, fall back to the techniques from Task 2 Step 1 (port-forward or `--resolve`).

### Step 4 — Change the script, watch the rollout

Edit `student/base/create-indexfile.sh` — for example, add a line:

```sh
echo "Hello from $(hostname)" | tee -a index.html
```

Re-apply:

```shell
kubectl apply -k student/overlays/dev
kubectl get pods -w
```

You should see a **new Pod** roll out, even though you only edited a shell script.
Why? `configMapGenerator` hashed the file's contents into the ConfigMap name.
New content → new ConfigMap name → Deployment spec changed → rolling update.
No `kubectl rollout restart` needed.

This is the single most useful Kustomize feature in production. Burn it into memory. 🔥

You can also see the new name of the config map being attached to the pod automatically:
`kubectl -n washere-dev describe pod $(kubectl -n washere-dev get pod -l app=washere -o name) | grep -A2 Volumes`

### Step 5 — A second environment

Create `student/overlays/prod/kustomization.yaml`. Start from your `dev` overlay and change:

- `namespace: washere-prod`,
- `env: prod`,
- patch the Deployment to `replicas: 3`,
- patch the Ingress host to `washere.ct.gdcc.io`.

Hint for the replica patch - same JSON6902 style you already used for the Ingress:
```yaml
# Style 2: strategic-merge patch
patches:
  - target: { kind: Deployment, name: washere }
    patch: |
      - op: replace
        path: /spec/replicas
        value: 3
```

Diff the two environments without applying anything first:

```shell
diff -u <(kubectl kustomize student/overlays/dev) \
        <(kubectl kustomize student/overlays/prod)
```

The diff should be small and tell a clear story. That is the whole point of overlays.

> ℹ️ Each overlay creates its **own** PVC. The two environments don't share storage.

If you have enough time left, feel free to `kubectl apply -k` and explore.

### Step 6 — Clean up

```shell
kubectl delete -k student/overlays/dev
kubectl delete -k student/overlays/prod   # if you did apply it...
```

## Next Task
After the next round of slides, we'll continue with [Task 4 — FluxCD](../task-4-fluxcd/README.md), where the same overlay folders become the input for an in-cluster FluxCD `kind: Kustomization`.