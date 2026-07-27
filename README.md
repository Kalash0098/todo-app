# To-Do App — End-to-End CI/CD Pipeline

A simple Flask to-do app deployed through a full CI/CD pipeline: Jenkins, Docker, Terraform, Ansible, and Kubernetes on AWS.

## Architecture

```
Developer pushes to GitHub
        |
        v
GitHub webhook triggers Jenkins
        |
        v
Stage 1: Checkout code
Stage 2: Security scan (Bandit - static analysis on source)
Stage 3: Build Docker image
Stage 4: Push image to Docker Hub
Stage 5: kubectl set image -> rolling update on live cluster
        |
        v
App running on Kubernetes, reachable via NodePort
```

Infrastructure provisioning is separate from the CI pipeline:

```
Terraform -> provisions EC2 instance + security group + key pair
Ansible   -> installs Docker, kubeadm/kubelet/kubectl, initializes
             single-node K8s cluster, installs Flannel CNI
kubectl   -> applies Deployment + Service manifests
```

Terraform/Ansible run manually, on-demand (infrastructure changes rarely).
Jenkins runs automatically on every push (code changes often).

## Tech stack

| Layer | Tool |
|---|---|
| App | Python / Flask |
| CI orchestration | Jenkins |
| Source security scan | Bandit |
| Containerization | Docker |
| Image registry | Docker Hub |
| Infrastructure provisioning | Terraform |
| Server configuration | Ansible |
| Orchestration | Kubernetes (kubeadm, single-node) |
| Cloud | AWS EC2 |

## Repo structure

```
.
├── app.py                  # Flask application
├── templates/index.html
├── static/style.css
├── requirements.txt
├── Dockerfile
├── Jenkinsfile              # CI pipeline definition
├── ec2.tf / providers.tf / terraform.tf   # infrastructure as code
├── playbook.yml             # Ansible - Docker + K8s cluster setup
├── inventory.ini            # Ansible inventory (gitignored - environment specific)
└── k8s/
    ├── deployment.yml
    └── service.yml
```

## Setup (from scratch)

1. **App**: `pip install -r requirements.txt && python app.py`
2. **GitHub**: push this repo
3. **Jenkins server**: EC2 instance, Jenkins + Docker + Terraform + Ansible installed
4. **Terraform**: `terraform init && terraform apply` — provisions the K8s node
5. **Ansible**: `ansible-playbook -i inventory.ini playbook.yml` — builds the cluster
6. **Kubernetes**: `kubectl apply -f k8s/deployment.yml -f k8s/service.yml`
7. **Jenkins job**: Pipeline script from SCM, pointed at this repo's `Jenkinsfile`, GitHub webhook configured for auto-trigger

From here, every push to `main` automatically rolls out to the live cluster.

## Debugging log — real issues hit and fixed

This project didn't go smoothly on the first try, and that's the point — every issue below was diagnosed and fixed from first principles, not copy-pasted from a tutorial.

- Jenkins wouldn't start — required Java 21, not 17 (Jenkins raised its minimum version)
- Docker permission denied — `jenkins` user needed adding to the `docker` group
- Bandit install failed — `externally-managed-environment` (PEP 668) on newer Ubuntu; fixed with `--break-system-packages`
- Bandit not found after install — pip installed it outside PATH; fixed by invoking via `python3 -m bandit`
- Docker Hub push failed — access token had read-only scope, needed read/write
- `apt-key` deprecated — modern Ubuntu removed it; switched to the `signed-by=` keyring method
- `kubeadm init` preflight failure — missing `br_netfilter` kernel module and sysctl bridge settings

