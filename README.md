# Navoy Assessment — Terraform + LocalStack + Node.js

Welcome to the Navoy Assessment Project, where we combine Infrastructure as Code (Terraform) with a Node.js app to model a real-world AWS-style architecture, all fully runnable locally using LocalStack Community.

🎯 Project Goals

✅ Infrastructure as Code (IaC) with Terraform

✅ AWS-aligned design: VPC, Subnets, EC2, IAM, etc.

✅ Fully local testing (no real AWS account required)

✅ Clear, complete, self-contained documentation

📁 Repository Overview

This repo contains:

🟢 A simple Node.js app: Hello Navoy

🛠️ A Terraform configuration that provisions:

VPC + Subnets (public/private)

Internet Gateway + routing

Security Groups

IAM role + instance profile (ECS-style)

Launch Template

Optional Auto Scaling Group (disabled by default)

A mock EC2 instance (via LocalStack APIs)

⚠️ Important: LocalStack Community mocks AWS APIs only. EC2 instances are not real machines – no reliable SSH or user_data execution.

📂 Repository Structure
.
├── Terraform/
│   ├── main.tf
│   ├── providers.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   └── Modules/
│       ├── Network/
│       │   └── main.tf
│       └── Compute/
│           └── main.tf
├── App
    ├── index.js
    ├──package.json

└── README.md
├──architecture.md
├──devops.md

🔧 Prerequisites

Make sure the following tools are installed:

🐳 Docker Desktop

🌍 Terraform ≥ 1.6

🧰 AWS CLI v2

📦 Node.js ≥ 18

📁 npm

✅ Verify Installation
docker --version
terraform -version
aws --version
node -v
npm -v

🟢 1. Run the JavaScript App (Local)

You can run the app without Terraform:

npm install
node index.js

By default, the app listens on port 3000.

Test it:

Or in PowerShell:

🔄 2. Start LocalStack

Run LocalStack in Docker:

localstack start -d

Check health:

⚙️ 3. Terraform Setup (LocalStack)

All Terraform code is in Terraform/.

cd Terraform
terraform init
terraform plan
terraform apply

Provider configuration uses LocalStack endpoints for:

ec2

iam

sts

autoscaling

ecs

All point to: `http://localhost:4566`

Use fake credentials: `AWS_ACCESS_KEY_ID=test`, `AWS_SECRET_ACCESS_KEY=test`

✅ 4. Validate Infrastructure
Terraform Outputs
terraform output

Expect:

VPC ID

Public & Private Subnet IDs

Launch Template Name

Mock EC2 Instance ID

AWS CLI Checks (LocalStack)

📦 5. App Deployment in LocalStack (Why It's Skipped)

In real AWS you could:

Install Docker via EC2 user_data

Use ECS on EC2 via Auto Scaling Group

Put an ALB in front

But in LocalStack Community:

EC2 is just an API mock

No actual OS boot

user_data is unreliable

SSH isn't supported

👉 Therefore:

Terraform validates infra design ✅

App is run locally (Node.js or Docker) ✅

Same code can later deploy to real AWS ✅

🧹 6. Clean Up

To destroy all infrastructure in LocalStack:

terraform destroy

📘 Documentation Notes
Modules/Network

VPC

Subnets

Routing

Security Groups

Modules/Compute

IAM role & Instance Profile

Launch Template

Optional Auto Scaling Group

Mock EC2 Instance

Architecture mirrors AWS while remaining verifiable locally.

🛠️ Troubleshooting
LocalStack not responding?
docker ps
curl `http://localhost:4566/_localstack/health`

Terraform issues?
terraform init -reconfigure

AWS CLI hitting real AWS?

Always use:

--endpoint-url=`http://localhost:4566`

✅ Conclusion

This repo demonstrates:

✅ Clean Infrastructure as Code with Terraform

✅ Realistic AWS-style architecture

✅ Fully local verification using LocalStack

✅ Honest documentation of platform limitations
