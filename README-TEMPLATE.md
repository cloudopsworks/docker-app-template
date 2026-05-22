# Docker App Template

This repository is the **CloudOps Works Docker application template** for bootstrapping a containerized service with a Docker image build pipeline, GitHub Actions workflows, and CloudOps Works CI/CD delivery wiring already in place.

Use this template when you want a repository that already includes:

- a container build pipeline producing a Docker image pushed to a registry
- CloudOps Works CI/CD configuration under `.cloudopsworks/`
- GitHub Actions workflows for PR validation, main builds, deploys, and cleanup
- deployment templates spanning AWS, Azure, and GCP targets
- API Gateway sample definitions under `apifiles/`
- Dual GitVersion presets (GitFlow and GitHub Flow)
- optional security scanning via Snyk, Semgrep, Trivy, and SonarQube

---

## What gets generated from this template

### Application scaffold
- `package.json` — package metadata, name, and semver version (managed by `make code/init`)
- `apifiles/` — API definition placeholders and samples
- `Makefile` — version helper and bootstrap targets powered by Tronador

### Delivery scaffold
- `.cloudopsworks/cloudopsworks-ci.yaml` — repository governance and deployment routing
- `.cloudopsworks/vars/inputs-global.yaml` — global build/deploy defaults
- `.cloudopsworks/vars/inputs-*.yaml` — deployment-target templates
- `.cloudopsworks/vars/preview/` — preview-environment defaults
- `.cloudopsworks/vars/apigw/` — API Gateway templates
- `.cloudopsworks/vars/helm/` — Helm values overrides
- `.cloudopsworks/_VERSION` — template version tracked by release automation
- `.cloudopsworks/gitversion_gitflow.yaml` — GitFlow reference configuration
- `.cloudopsworks/gitversion_githubflow.yaml` — GitHub Flow reference configuration
- `.github/workflows/` — reusable CI/CD orchestration

---

## Recommended bootstrap flow

### 1. Create a repository from this template
Create a new repository from `cloudopsworks/docker-app-template`, then clone it locally.

### 2. Initialize the package metadata
```bash
make code/init
```
This sets `package.json.name` to `@<github-owner>/<repo-name>` and `package.json.version` from GitVersion.

### 3. Update application metadata
Review and replace:
- `package.json` — name, description, scripts (`build`, `test`, `start`), dependencies
- `README.md` — service description, architecture notes, runbook links

### 4. Choose a branching model
```bash
# For GitFlow (develop, feature/*, release/*, hotfix/*)
cp .cloudopsworks/gitversion_gitflow.yaml .cloudopsworks/gitversion.yaml

# For GitHub Flow (main/master, short-lived feature branches)
cp .cloudopsworks/gitversion_githubflow.yaml .cloudopsworks/gitversion.yaml
```

### 5. Configure CloudOps Works settings
Update `.cloudopsworks/cloudopsworks-ci.yaml`:
- `branchProtection`, `gitFlow.enabled`, `requiredReviewers`, `reviewers`, `owners`, `contributors`
- `cd.deployments` — branch/tag to environment mapping

### 6. Configure global inputs
Set these in `.cloudopsworks/vars/inputs-global.yaml` before the first pipeline run:
- `organization_name`, `organization_unit`, `environment_name`, `repository_owner`
- `cloud` — `aws`, `azure`, or `gcp`
- `cloud_type` — deployment mechanism matching the target
- Optional: `docker_image`, `docker_inline`, `docker_args`, `custom_run_command`
- Optional: `snyk`, `semgrep`, `trivy`, `sonarqube` — security tooling

---

## Choose a deployment target

Each active environment uses exactly one target file under `.cloudopsworks/vars/`.

### Kubernetes / EKS / AKS / GKE
Use `inputs-KUBERNETES-ENV.yaml`.

Key fields: `container_registry`, `cluster_name`, `namespace`, `helm_values_overrides`

### AWS Lambda
Use `inputs-LAMBDA-ENV.yaml`.

Key fields: `versions_bucket`, `aws.region`, `lambda.handler`, `lambda.runtime`

### AWS Elastic Beanstalk
Use `inputs-BEANSTALK-ENV.yaml`.

Key fields: `versions_bucket`, `container_registry`, `aws.region`

### Google App Engine
Use `inputs-APPENGINE.yaml`.

Key fields: `container_registry`, `gcp.region`, `gcp.project_id`, `appengine.runtime`

### Google Cloud Run
Use `inputs-CLOUDRUN.yaml`.

Key fields: `container_registry`, `gcp.region`, `gcp.project_id`, `cloudrun.type`

### Docker / Kubernetes (lightweight)
Use `inputs-DOCKER-ENV.yaml`.

Key fields: `container_registry`, `cluster_name`, `namespace`

---

## Docker image customization

Container build behavior is controlled from `inputs-global.yaml`. No Dockerfile is committed to the template — the pipeline generates one from the base image and optional inline instructions.

| Field | Purpose |
|-------|---------|
| `docker_image` | Base image (default: `node:18-alpine`) |
| `docker_inline` | Raw Dockerfile instructions injected at build time |
| `docker_args` | `--build-arg` values |
| `custom_run_command` | Override default container `CMD` |
| `custom_usergroup` | Non-root user/group creation for slim base images |

---

## Optional features

### Preview environments
Enable in `inputs-global.yaml`:
```yaml
preview:
  enabled: true
```
Configure from `.cloudopsworks/vars/preview/`.

### API Gateway publication
Enable in `inputs-global.yaml`:
```yaml
apis:
  enabled: true
```
API definitions are read from `apifiles/`. Configure per-environment files under `.cloudopsworks/vars/apigw/`.

### Helm values overrides
For Kubernetes targets, per-environment Helm overrides live under `.cloudopsworks/vars/helm/`.

---

## GitHub Actions workflow model

Key workflows in this template:

- `main-build.yml` — build, containerize, scan, release/deploy on branch/tag events
- `pr-build.yml` — PR validation and optional preview deployment
- `deploy-container.yml` — push application container artifacts
- `deploy.yml` — standard deployment flow
- `scan.yml` — SAST/SCA orchestration
- `pr-close.yaml` — post-merge/tag cleanup
- `automerge.yml`, `process-owners.yml` — repository automation

---

## Minimum checklist before first release

- [ ] Update `package.json` name, description, scripts, and dependencies for the real service
- [ ] Choose a GitVersion preset and copy it to `.cloudopsworks/gitversion.yaml`
- [ ] Replace all placeholders in `inputs-global.yaml` (`ORG_NAME`, `ORG_UNIT`, `ENV_NAME`, `REPO_OWNER`)
- [ ] Set real `cloud` and `cloud_type` values
- [ ] Fill in exactly one target-specific `inputs-*.yaml` per active environment
- [ ] Configure GitHub environment secrets for each deployment environment
- [ ] Update `README.md` to describe the actual service
- [ ] CI passes on a pull request

---

## Notes

- `.omx/`, `.claude/`, `.opencode/`, and similar agent/tooling directories are intentionally ignored and are not part of the application template contract.
- The template is designed for CloudOps Works blueprint-backed automation; if you remove that integration, also prune the related workflows and `.cloudopsworks/` configuration.
- When adding a new deployment target, add the `# Agents:` comment header to the inputs file (e.g., `# Agents: cloud=aws ; cloud_type=newtype`) for tooling discoverability.

---

## AI-assisted upgrade of `.cloudopsworks/vars` configuration files

This section is a machine-readable protocol for AI agents performing a seamless, non-destructive upgrade of all configuration files under `.cloudopsworks/vars/` when a new template version is released. Follow the steps below in order.

### Upgrade overview

The template version locked into this repository is recorded in `.cloudopsworks/_VERSION`. The canonical upstream source is the GitHub repository `cloudopsworks/docker-app-template`, pinned to the tag that matches the content of `_VERSION`.

An upgrade merges new keys, updated comments, and structural changes from the upstream template into local files **without overwriting values the operator has already set**.

---

### Step 1 — determine current and target versions

1. Read `.cloudopsworks/_VERSION` to get the **current locked version** (e.g., `v1.4.15`).
2. The **target version** is either supplied by the operator or is the latest release tag on `cloudopsworks/docker-app-template`.
3. Fetch any upstream file from GitHub using the pattern:
   ```
   https://raw.githubusercontent.com/cloudopsworks/docker-app-template/<version>/<path>
   ```
   Example:
   ```
   https://raw.githubusercontent.com/cloudopsworks/docker-app-template/v1.4.15/.cloudopsworks/vars/inputs-global.yaml
   ```

---

### Step 2 — identify the deployment type for each environment file

Each `inputs-<name>.yaml` file under `.cloudopsworks/vars/` maps to a specific upstream template. Determine the type using the following priority order:

**Priority 1 — `Agents:` header comment**

If the file contains an `# Agents:` line in its header block, read `cloud` and `cloud_type` directly from it:

```yaml
# Agents: cloud=aws ; cloud_type=device-farm
```

**Priority 2 — fallback to `inputs-global.yaml`**

If no `# Agents:` line is present, read the active `cloud` and `cloud_type` values from `.cloudopsworks/vars/inputs-global.yaml` and apply the mapping table below.

**`cloud` / `cloud_type` → upstream template file:**

| `cloud`                  | `cloud_type`                   | Upstream template file         |
|--------------------------|--------------------------------|--------------------------------|
| `aws`                    | `eks` or `kubernetes`          | `inputs-KUBERNETES-ENV.yaml`   |
| `azure`                  | `aks` or `kubernetes`          | `inputs-KUBERNETES-ENV.yaml`   |
| `gcp`                    | `gke` or `kubernetes`          | `inputs-KUBERNETES-ENV.yaml`   |
| `aws`                    | `lambda`                       | `inputs-LAMBDA-ENV.yaml`       |
| `aws`                    | `beanstalk`                    | `inputs-BEANSTALK-ENV.yaml`    |
| `gcp`                    | `appengine`                    | `inputs-APPENGINE.yaml`        |
| `gcp`                    | `cloudrun`                     | `inputs-CLOUDRUN.yaml`         |
| `aws` / `gcp` / `azure`  | `kubernetes` (Docker variant)  | `inputs-DOCKER-ENV.yaml`       |
| `aws` / `gcp` / `azure`  | `none` or library mode         | `inputs-LIB-ENV.yaml`          |

`inputs-global.yaml` always maps to the upstream `inputs-global.yaml` regardless of cloud type.

---

### Step 3 — merge environment-specific files

For each `inputs-<name>.yaml`, apply all of the following rules.

#### Keys and values

- **Preserve operator-set values** — any key whose local value differs from the upstream template's placeholder or default must be kept exactly as-is.
- **Add missing keys** — keys present in the upstream template but absent locally must be inserted at the correct structural position using the upstream default value and comment.
- **Flag removed keys** — keys present locally but deleted from the upstream template must be reported to the operator before removal; do not silently delete them.

#### Comments

- **Template comments are authoritative for unchanged sections** — section-level and field-level comments from the upstream template replace their local equivalents when the operator has made no additions to that comment block.
- **Preserve operator-added comments** — any comment not present in the upstream template must be retained verbatim.
- **Update the `Agents:` header line** — if the upstream template added or changed the `# Agents:` metadata line, update it in the local file without altering the first description line (`# This file contains...`).

#### Formatting

- **Match upstream indentation and quoting** — indentation, block vs. flow style, and quoted vs. unquoted strings must match the upstream template for any unchanged or newly added sections.
- **Commented-out blocks** — blocks that are commented out in the upstream template must remain commented out unless the operator has explicitly uncommented them locally.
- **Multiline scalars** — preserve the operator's choice of `|` vs. `>` for any multiline value the operator has set.

---

### Step 4 — merge `inputs-global.yaml`

`inputs-global.yaml` requires special handling because it contains mandatory operator identity fields alongside a large body of optional commented-out sections.

Merge procedure:

1. **Retain the four mandatory identity fields** verbatim at the top of the file:
   ```yaml
   organization_name: "..."
   organization_unit: "..."
   environment_name: "..."
   repository_owner: "..."
   ```
2. **Retain `cloud` and `cloud_type`** exactly as the operator set them.
3. **For every optional commented-out section** in the upstream template, check the local file:
   - If the operator **has uncommented and configured it** — keep the operator's values; update only surrounding comment text if it changed upstream.
   - If the section **is still fully commented out locally** — replace the entire commented block with the upstream version, capturing any new fields or updated documentation within it.
4. **Append new optional sections** that appear in the upstream template but are entirely absent locally, in fully commented-out form, preserving their upstream position and comments.

---

### Step 5 — upgrade subdirectory files

Apply the same merge rules (Steps 3 and 4) to every file in the following subdirectories, matching each local file to its corresponding upstream file at the same relative path:

- `.cloudopsworks/vars/preview/inputs.yaml`
- `.cloudopsworks/vars/preview/values.yaml`
- `.cloudopsworks/vars/apigw/apis-global.yaml`
- `.cloudopsworks/vars/apigw/apis-dev.yaml`
- `.cloudopsworks/vars/apigw/apis-uat.yaml`
- `.cloudopsworks/vars/apigw/apis-prod.yaml`
- `.cloudopsworks/vars/helm/values-dev.yaml`
- `.cloudopsworks/vars/helm/values-uat.yaml`
- `.cloudopsworks/vars/helm/values-prod.yaml`

---

### Step 6 — update `_VERSION`

After all merges are verified correct, write the target version string (e.g., `v1.4.16`) to `.cloudopsworks/_VERSION`. This is the final step.

---

### Upgrade invariants

An agent performing this upgrade must **never**:

- Overwrite a field the operator has explicitly set to a non-placeholder value.
- Remove a commented-out operator value without first reporting it.
- Change the YAML structure of any active (uncommented) operator section.
- Alter a file's opening description comment (`# This file contains...`) unless the upstream version changed it.
- Modify `.cloudopsworks/cloudopsworks-ci.yaml`, `gitversion_*.yaml`, or any file under `.github/workflows/` as part of a vars upgrade — those follow their own upgrade path.
- Update `_VERSION` before all file merges are complete.

---

### Conflict resolution

When a merge cannot be resolved automatically (for example, the upstream template restructured a section that the operator has customized):

1. Emit a diff showing both the upstream template block and the local operator block side by side.
2. Pause and present the conflict to the operator, asking which version to keep or whether a manual merge is needed.
3. Never silently choose one side.
