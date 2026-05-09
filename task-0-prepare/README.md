<!--
SPDX-FileCopyrightText: 2026 Forschungszentrum Jülich GmbH
SPDX-FileContributor: Oliver Bertuch

SPDX-License-Identifier: CC-BY-4.0
-->

# Task 0 - Prepare Yourself At Home
## Summary
- Checking prerequisites
- Making sure basic stuff is squared away before the workshop

## Step 1 - Hardware
Check your laptop: if you have less than 16G of RAM, or less than 4 CPUs, get a different one.
There are no other laptops or VMs around and 16G is cutting it close.
You are also welcome to run K8s on a remote host if that's easier for you, but you may run into compatibility
problems with storage and ingress definitions (these are the most tricky bits).

## Step 2 - Git
We will make use of Git a lot, but there will be no introduction.
If you don't have much experience or want to brush up: please prepare run through one or more Git tutorials.
We won't do anything fancy with Git – you need to know the basic workflow and its commands like `add`, `commit`, `push`, and `pull`.

If you don't have Git installed, are fine with command line use, and dislike your IDEs Git client,
please [install Git as a command line tool](https://git-scm.com/install/).

## Step 3 - GitHub
We will use GitHub for our exercises. Please create:
1. A Github account and let me know which that is.
2. A Github Personal Access Token for FluxCD. (Please don't send me that, it's a secret. But write it down some place secure!)

## Step 4 - Tooling
Please have these at the ready:
1. FluxCD client (https://fluxcd.io/flux/cmd/)
2. An editor or IDE you like. I very much encourage you to use something with good syntax highlighting for YAML.
   Here are some options: [Zed](https://zed.dev/), [IntelliJ IDEA](https://www.jetbrains.com/idea), or [VS Code](https://code.visualstudio.com/).

## Next Task
Please continue by executing [Task 1 - Setup K8s](../task-1-setup-k8s/README.md) to make sure we don't lose too much time with setup and bandwidth problems onsite. (Images will be cached locally unless you delete them.)