# Dockerized CI/CD Pipeline on AWS with ALB and Auto Scaling Group

## Project Overview

This project demonstrates a Dockerized CI/CD pipeline that automatically builds, versions, and deploys a containerized web application to AWS infrastructure using GitHub Actions, Docker Hub, EC2, Application Load Balancer, Launch Template, and Auto Scaling Group.

The project started as a simple EC2 deployment and was upgraded into a more production-style architecture with load balancing, health checks, runtime instance metadata injection, and rolling instance refresh deployments.

---

## Architecture
```text
Developer
   |
   | git push
   v
GitHub Repository
   |
   v
GitHub Actions Workflow
   |
   | Build Docker image
   | Tag image as latest + Git commit SHA
   | Push image to Docker Hub
   | Trigger ASG Instance Refresh
   v
Docker Hub
   |
   v
AWS Auto Scaling Group
   |
   | Launch Template User Data
   | Install Docker
   | Pull latest Docker image
   | Run Nginx container
   | Inject EC2 metadata into HTML
   v
EC2 Instances
   |
   v
Application Load Balancer
   |
   v
Users access the app through ALB DNS

```
## Tech Stack
- AWS EC2
- Application Load Balancer
- Auto Scaling Group
- Launch Template
- Security Groups
- GitHub Actions
- Docker
- Docker Hub
- Nginx
- Amazon Linux 2023
- Bash / User Data
- EC2 Instance Metadata Service
- IAM

## Key Features
- Automated CI/CD pipeline using GitHub Actions
- Dockerized static web application served through Nginx
- Docker image tagging using both latest and Git commit SHA
- Docker image pushed to Docker Hub
- Infrastructure provisioned using Terraform
- Reusable Terraform variables and outputs
- EC2 Launch Template user data managed through Terraform
- Auto Scaling Group and ALB provisioned through Infrastructure as Code
- Application deployed behind an AWS Application Load Balancer
- Auto Scaling Group launches EC2 instances automatically
- Launch Template user data installs Docker and runs the container
- ALB health check configured using /health.html
- Runtime EC2 metadata injection into the web page
- ASG Instance Refresh used for rolling deployments
- Container restart policy configured using --restart unless-stopped
- EC2 application access restricted through Security Groups

## Deployment Flow
- Developer pushes code to the main branch.
- GitHub Actions workflow starts automatically.
- Workflow logs in to Docker Hub.
- Docker image is built from the Dockerfile.
- Image is tagged with:
  - latest
  - short Git commit SHA
- Both tags are pushed to Docker Hub.
- GitHub Actions authenticates to AWS using IAM credentials stored in GitHub Secrets.
- GitHub Actions triggers an Auto Scaling Group Instance Refresh.
- ASG replaces instances gradually.
- New EC2 instances run Launch Template user data.
- User data installs Docker, pulls the latest image, runs the container, and injects EC2 metadata.
- ALB routes traffic only to healthy instances.

## Docker Image Versioning

The pipeline creates two Docker tags for each build:
- project-3-cicd-web:latest
- project-3-cicd-web:<commit-sha>

Example:
- project-3-cicd-web:latest
- project-3-cicd-web:a1b2c3d

The latest tag is used for deployment, while the commit SHA tag provides traceability and rollback capability.

## Runtime Metadata Injection

Each EC2 instance retrieves its own metadata using the EC2 Instance Metadata Service:
- Instance ID
- Private IP address
- Availability Zone

This metadata is injected into the HTML pages at container startup using user data and sed.
This allows the webpage to display which backend EC2 instance served the request, making ALB load balancing visible during testing.

## Health Check

The application includes a dedicated health check endpoint:
- /health.html

The ALB target group uses this endpoint to verify whether each backend EC2 instance is healthy before routing traffic to it.

## Security Design

- Public users access the application through the ALB DNS endpoint.
- EC2 instances receive application traffic only from the ALB security group.
- Docker Hub token is stored securely in GitHub Secrets.
- AWS access keys are stored securely in GitHub Secrets.
- IAM policy grants GitHub Actions permission to trigger ASG Instance Refresh.
- EC2 user data handles bootstrapping automatically.

## GitHub Actions Workflow Summary

The workflow performs the following actions:
- Checkout code
- Login to Docker Hub
- Create image tag from Git commit SHA
- Build Docker image
- Push Docker image to Docker Hub
- Configure AWS credentials
- Trigger ASG Instance Refresh

## Important Lessons Learned

- Docker containers require host-to-container port mapping.
- Public subnet route to an Internet Gateway is not enough unless the instance has a public IP.
- ALB health checks must match the correct target port and path.
- User data only runs when a new EC2 instance launches.
- Existing ASG instances do not automatically pull new Docker images.
- ASG Instance Refresh can be used to roll out new versions across instances.
- EC2 Instance Metadata Service v2 requires a token-based request.
- Security Groups should restrict EC2 traffic to the ALB instead of exposing instances directly.

## Future Improvements

- Convert the AWS infrastructure into Terraform
- Add CloudWatch alarms and dashboards
- Add deployment approval environments in GitHub Actions
- Add rollback workflow using commit-based Docker tags
- Move EC2 instances into private subnets with NAT Gateway
- Add HTTPS using ACM and ALB listener on port 443

## Project Status

Completed as a hands-on DevOps portfolio project demonstrating:
- CI/CD automation
- Docker
- AWS ALB
- ASG
- rolling deployments

## Architecture Diagram

```mermaid
flowchart TD
    A[Developer Pushes Code to GitHub] --> B[GitHub Actions Workflow]

    B --> C[Build Docker Image]
    C --> D[Tag Image: latest + Git SHA]
    D --> E[Push Image to Docker Hub]
    E --> F[Trigger ASG Instance Refresh]

    T[Terraform Infrastructure as Code] --> V[VPC]
    T --> S[Public Subnets across 2 AZs]
    T --> SG[Security Groups]
    T --> ALB[Application Load Balancer]
    T --> TG[Target Group]
    T --> LT[Launch Template]
    T --> ASG[Auto Scaling Group]

    F --> ASG
    ASG --> LT
    LT --> EC2[EC2 Instances]

    EC2 --> UD[User Data Script]
    UD --> DCK[Install Docker]
    DCK --> PULL[Pull Latest Docker Image]
    PULL --> RUN[Run Nginx Container]
    RUN --> META[Inject EC2 Metadata into HTML]

    EC2 --> TG
    TG --> ALB
    ALB --> USER[Users Access Application via ALB DNS]

    TG --> HC[Health Check: /health.html]
```

# What this shows

This diagram explains the full lifecycle:

```text
GitHub push
→ GitHub Actions
→ Docker build
→ Docker Hub
→ ASG refresh
→ new EC2 instances
→ Docker container starts
→ ALB serves traffic
```

This architecture demonstrates a containerized CI/CD deployment pipeline on AWS.  
Code changes pushed to GitHub trigger a GitHub Actions workflow, which builds and versions a Docker image, pushes it to Docker Hub, and refreshes the Auto Scaling Group. New EC2 instances launched through the Launch Template automatically install Docker, pull the latest image, run the containerized Nginx application, and register behind the Application Load Balancer. The ALB performs health checks using `/health.html` and routes traffic only to healthy instances.


## Screenshots

### 1. GitHub Actions CI/CD Workflow Success
Shows the pipeline successfully building the Docker image, pushing it to Docker Hub, and triggering the Auto Scaling Group instance refresh.

![GitHub Actions Success](screenshots/github-actions-success1.png)
![GitHub Actions Success](screenshots/github-actions-success2.png)
---

### 2. Live Application via ALB
Shows the deployed application being served through the Application Load Balancer DNS endpoint.

![ALB Main Page](screenshots/alb-main-page1.png)
![ALB Main Page](screenshots/alb-main-page2.png)

---

### 3. Health Check Endpoint
Shows the `/health.html` endpoint returning a healthy response with instance metadata.

![Health Check](screenshots/health-check1.png)
![Health Check](screenshots/health-check2.png)
![Health Check](screenshots/health-check3.png)
---

### 4. Auto Scaling Group Instance Refresh
Shows ASG rolling deployment replacing old instances with new ones.

![ASG Instance Refresh](screenshots/asg-instance-refresh1.png)
![ASG Instance Refresh](screenshots/asg-instance-refresh2.png)

---

### 5. Target Group Health Checks
Shows EC2 instances registered behind the ALB and passing health checks.

![Target Group Healthy](screenshots/target-group-healthy.png)

## Project 3B: Terraform Infrastructure as Code Upgrade

This project was upgraded with Terraform to provision the AWS infrastructure using Infrastructure as Code instead of creating resources manually through the AWS Console.

Terraform is used to create and manage the networking, load balancing, security, compute, and scaling components required to run the Dockerized application on AWS.

---

## Terraform Architecture

```text
Terraform
   |
   | provisions
   v
AWS Infrastructure
   |
   |-- VPC
   |-- Public Subnets across 2 Availability Zones
   |-- Internet Gateway
   |-- Route Table
   |-- Security Groups
   |-- Application Load Balancer
   |-- Target Group
   |-- ALB Listener
   |-- Launch Template
   |-- Auto Scaling Group
   v
EC2 Instances
   |
   | user data
   v
```
Install Docker → Pull Docker Image → Run Nginx Container → Inject EC2 Metadata

## Terraform-Managed Resources
- Custom VPC
- Two public subnets across multiple Availability Zones
- Internet Gateway
- Public route table and subnet associations
- ALB security group
- EC2 security group
- Application Load Balancer
- Target Group with /health.html health checks
- HTTP listener on port 80
- Launch Template using Amazon Linux 2023
- Auto Scaling Group attached to the ALB target group
- EC2 user data script for Docker bootstrapping

## Terraform Deployment Flow
- Terraform provisions the VPC, public subnets, Internet Gateway, route table, and security groups.
- Terraform creates an internet-facing Application Load Balancer.
- Terraform creates a target group using port 8080 and health check path /health.html.
- Terraform creates a Launch Template using Amazon Linux 2023.
- Launch Template user data installs Docker, pulls the latest Docker image from Docker Hub, runs the Nginx container, and injects EC2 instance metadata into the application UI.
- Terraform creates an Auto Scaling Group across two public subnets.
- The ASG registers EC2 instances with the ALB target group.
- The ALB routes traffic only to healthy EC2 instances.

## Terraform + CI/CD Integration
Terraform provisions the infrastructure, while GitHub Actions handles the application deployment lifecycle.

```text
Terraform
   ↓
Creates AWS infrastructure

GitHub Actions
   ↓
Builds Docker image
Pushes image to Docker Hub
Triggers ASG Instance Refresh

ASG
   ↓
Launches new EC2 instances
Runs user data
Pulls latest image
Registers healthy targets behind ALB
```

