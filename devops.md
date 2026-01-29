# 🔧 DEVOPS.md

This document answers the DevOps reasoning questions required for the assignment.
The focus is on **pragmatic, production-oriented decisions**, aligned with the proposed AWS architecture, while remaining honest about local (LocalStack) constraints.

---

## 1) How Would You Manage Secrets?

### In Real AWS (Production)

Secrets would be managed using **AWS Secrets Manager** or **AWS Systems Manager Parameter Store**.

- Secrets are **never stored in Git** or baked into Docker images
- Secrets are injected at runtime via:
  - ECS task definition environment variables
  - Or retrieved dynamically by the application using IAM roles
- Access is controlled using **IAM least privilege**:
  - Each ECS task role can access only the secrets it needs

### Examples of secrets

- Database credentials
- API keys
- OAuth tokens

### Locally (LocalStack)

- Secrets are **mocked using environment variables**
- `.env` files are excluded from version control
- This keeps local execution simple while preserving the same runtime contract

### Trade-off

- LocalStack does not fully emulate Secrets Manager behavior
- Design mirrors production, implementation is simplified locally

---

## 2) How Would You Monitor This System?

### Baseline Monitoring (AWS-Native)

- **CloudWatch Logs**
  - Application logs (stdout/stderr)
  - ECS task lifecycle events
- **CloudWatch Metrics**
  - CPU and memory utilization (ECS service & EC2)
  - Load balancer health checks and error rates
- **CloudWatch Alarms**
  - High CPU/memory
  - Unhealthy targets
  - Instance failures

This provides:

- Immediate visibility
- Tight integration with AWS services
- Low operational overhead

### Advanced / Future Monitoring (Optional)

- **Prometheus + Grafana** (design-only)
  - Custom application metrics
  - Advanced dashboards
  - Long-term trend analysis

**Why not required now

- Single-service application
- CloudWatch is sufficient and simpler for early-stage systems

---

## 3) How Would You Handle Rollbacks?

### Deployment Model

- Deployments are **immutable**
- Each deployment produces:
  - A new Docker image (tagged with commit SHA)
  - A new ECS task definition revision

### Rollback Strategy

- Rollback = redeploy a **previous task definition revision**
- Or re-point the ECS service to a previous image tag

**Benefits

- Fast and deterministic
- No in-place modification
- Minimal downtime using ECS rolling deployments

### CI/CD Support

- GitHub Actions keeps build history
- Each deployment is traceable to a commit SHA
- Rollbacks do not require rebuilding images

---

## 4) What Would You Improve With More Time?

### Infrastructure

- Introduce **ECS Capacity Providers** for tighter ASG + ECS integration
- Add **multi-region disaster recovery** (if required by business)
- Improve network egress controls (VPC endpoints, tighter outbound rules)

### CI/CD

- Add automated tests (unit + smoke tests)
- Add security scans (Trivy, Snyk)
- Add policy-as-code (OPA / tfsec)

### Observability

- Custom application metrics
- Distributed tracing (AWS X-Ray or OpenTelemetry)

### Platform Evolution

- Evaluate migration from ECS to **EKS** when:
  - Multiple services exist
  - Teams need Kubernetes-native tooling
  - Operational maturity increases

---

## 5) Key Assumptions & Limitations

- LocalStack Community has **partial AWS emulation**
- Some behaviors (ALB, autoscaling) are simplified locally
- The design reflects **real AWS production best practices**
- The goal is **clarity, reasoning, and verifiability**, not feature completeness

---

## Summary

This DevOps approach prioritizes:

- Simplicity over premature complexity
- Immutable infrastructure and deployments
- Clear separation between **design intent** and **local execution constraints**
- A credible path from a single VM to a scalable AWS-native platform
