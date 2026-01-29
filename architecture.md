# 📐 ARCHITECTURE.md

## Context & Goals

Navoy currently runs a JavaScript application on a single virtual machine. The goal is to evolve this into a **cloud-native AWS architecture** that is:

- ⚖️ **Scalable** – Horizontally scalable behind a load balancer  
- 🔒 **Secure-by-default** – Least privilege, network segmentation  
- 🔁 **Reliable** – Self-healing, health checks, rolling deployments  
- 🧪 **Verifiable locally** – Via **LocalStack** + Terraform (no AWS account required)

This repository implements an **AWS-aligned design** along with a **LocalStack-compatible** subset for local testing.

---

## 1) Proposed AWS Architecture (Reference Design)

### 🧩 Core Runtime (What Serves Traffic)

- **VPC** spanning **2 Availability Zones**
  - **Public subnets**: Host the Application Load Balancer (ALB)
  - **Private subnets**: Run ECS tasks and container instances (EC2 launch type)
  
- **ALB (Application Load Balancer)**
  - Terminates HTTP/HTTPS (real AWS uses ACM for HTTPS)
  - Routes traffic to ECS targets
  - Performs health checks for automated failover

- **Amazon ECS (EC2 Launch Type)**
  - **ECS Cluster** powered by an **Auto Scaling Group (ASG)** of ECS-optimized EC2 instances
  - **ECS Service** runs multiple tasks (Node.js container)
  - Task definitions reference Docker images stored in ECR

### 🗂️ Image Storage

- **Amazon ECR** stores versioned Docker container images.

### 🔐 Secrets Management

- **AWS Secrets Manager** or **SSM Parameter Store**
  - Inject secrets at runtime (never stored in Git or Docker images)

### 📊 Observability

- **CloudWatch Logs** for application logs
- **CloudWatch Metrics/Alarms** for monitoring
- (Optional, design-only) **Prometheus/Grafana** for enhanced dashboards

> **Why ECS EC2 over Fargate?**

- Demonstrates capacity management and auto-scaling concepts  
- Aligns with "VM to managed orchestration" migration thinking  
- Trade-off: More operational overhead (e.g., patching EC2 hosts)

---

## 2) Local Implementation (LocalStack-Compatible Subset)

LocalStack Community does not fully emulate all AWS behaviors (notably ALB/ECS integrations depending on versions).
Therefore, the repository provides a **locally verifiable subset** while keeping the **same AWS-oriented design intent**.

### What is runnable locally

- VPC, subnets, route tables, security groups
- Compute layer: **EC2-based container runtime** (Docker on EC2) to host the JS container
- Load balancing: **LocalStack-compatible LB option** (documented in README)
- App is reachable locally through the exposed endpoint

### What remains reference-only (real AWS)

- ECS Service Auto Scaling + ASG capacity providers
- ALB advanced routing/health check behavior exactly matching AWS
- Secrets Manager / SSM integration (locally mocked)

**Rationale:** we prioritize the assignment’s verifiability requirement (terraform apply + reachable app) while preserving a credible AWS production path.

---

## 3) Scalability Strategy

### 🔹 Layer A – Scaling Containers (ECS Service Auto Scaling)

- Dynamically adjusts the **number of ECS tasks**
- Example policies:
  - Target-tracking on CPU (e.g., 60%)
  - Target-tracking on memory (e.g., 70%)
  - In real AWS: ALB RequestCountPerTarget for request-based scaling

**Why this matters:**  
Fast reaction to traffic spikes without needing to scale EC2 instances (if spare capacity exists).

---

### 🔸 Layer B – Scaling Compute (Auto Scaling Group / Capacity Providers)

- **Auto Scaling Group (ASG)** adds/removes ECS container instances
- In AWS: use **ECS Capacity Providers** to bind ECS service needs to ASG scaling

**Trade-off:**  
More complex than Fargate, but clearly separates **task scaling** from **host scaling**.

---

## 4) Reliability & Security

### 🔁 Reliability

- **Multi-AZ** deployment: ALB and ASG span at least 2 Availability Zones
- **Health Checks**:
  - ALB removes unhealthy targets
  - ECS replaces unhealthy tasks automatically
- **Rolling Deployments**:
  - ECS uses rolling updates (via min/max healthy percent)

**Why:**  
Eliminates single points of failure from the single-VM model and enables self-healing.

---

### 🔐 Security

- **Network Segmentation**:
  - ALB in public subnets
  - ECS/EC2 in private subnets

- **Security Groups**:
  - ALB SG: allows inbound traffic from the internet (ports 80/443), outbound to ECS
  - ECS SG: allows inbound only from ALB on the app port

- **IAM Roles (Least Privilege)**:
  - Task execution role: pull from ECR + write logs
  - Task role: minimal AWS permissions
  - Instance role: allows ECS agent operations

- **Secrets**:
  - No hardcoded secrets
  - Secrets injected at runtime via AWS Secrets Manager or SSM

**Note:**  
Local setup simplifies some security controls for ease of testing, but the design logic mirrors production best practices.

---

## 5) CI/CD Strategy (GitHub Actions)

### 🛠️ Pipeline Steps

1. **CI Checks**
   - Install dependencies, optional linting/testing
2. **Build Docker Image**
   - Tag with Git commit SHA (e.g., `sha-<GITHUB_SHA>`)
3. **Push Image to Registry**
   - Preferred: Amazon ECR
4. **Deploy**
   - Real AWS: Update ECS task definition and ECS service

**Why:**  
The Docker image is an immutable deployment artifact.  
Rollbacks are as easy as reusing an earlier image tag or task definition revision.

---

## 6) Key Trade-offs & Assumptions

### ECS (EC2) vs Fargate

- ✅ **ECS EC2 chosen**: Clearer demonstration of scaling and infrastructure layers  
- ⚠️ **Trade-off**: More operational complexity

### ALB vs Simpler Ingress

- ✅ **ALB chosen**: Standard ingress with health checks and deployment safety  
- ⚠️ **Trade-off**: More components and setup complexity

### Secrets Manager

- ✅ Design includes Secrets Manager  
- 🧪 Locally, secrets are mocked via environment variables or local files

### Monitoring (Prometheus/Grafana)

- ✅ Optional; AWS-native observability via CloudWatch is sufficient  
- 📊 Prometheus/Grafana suited for advanced use cases (multi-cluster, custom metrics)

### LocalStack Constraints

- LocalStack used for validating IaC and service integration locally  
- Some AWS behaviors may differ; any known limitations are documented in the repo

## Kubernetes / EKS (Future Scope – Not Implemented)

Kubernetes (EKS) is **design-only** for this assignment and **not part of the local runnable stack**.
It is included as a future evolution path once the ECS-based platform is stable.

### Why EKS later

- Standardization across teams/workloads
- Richer ecosystem (operators, service mesh, advanced policy)
- Strong fit when multiple services and complex deployments appear

### Why not now

- The assignment requires **local verifiability with LocalStack**
- EKS cannot be realistically validated in LocalStack Community
- ECS provides a simpler, AWS-native migration step from the current single VM

---

## 🖼️ Architecture Diagram

![Architecture Diagram](docs/architecture.png)
