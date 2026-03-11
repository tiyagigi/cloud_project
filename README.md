# Group 7 DevOps Portfolio

Welcome! This repository contains the code for a Static Portfolio Site deployed via GitOps and a Global Content Delivery System (CDN) setup, fulfilling all Group 7 requirements.

## Overview

- **Part 1 (Static Portfolio):** Simple HTML/Tailwind portfolio inside an Nginx container. Includes Terraform DNS configurations (AWS Route 53 pointing to EKS) and GitHub Actions for continuous delivery (posting `terraform plan` on Pull Requests).
- **Part 2 (Global CDN):** Terraform configuration for a CloudFront distribution with an S3 origin. Includes a local Nginx proxy configuration mimicking a CDN cache and a GitHub Actions workflow to invalidate the cache using AWS CLI.
- **Monitoring:** Includes a Prometheus configuration to scrape Nginx 404 errors.

---

## 🚀 Prerequisites Setup Guide

Since this project requires several tools, follow these steps to get your environment ready:

### 1. Install Docker Desktop (with WSL2)
To run the project locally and simulate the CDN cache, you need Docker.
1. Download [Docker Desktop for Windows](https://docs.docker.com/desktop/install/windows-install/).
2. Run the installer. Ensure that the **"Use WSL 2 instead of Hyper-V"** option is checked during installation.
3. Once installed, start Docker Desktop.
4. Verify by opening a terminal (PowerShell or Command Prompt) and running: `docker --version`.

### 2. Create an AWS Account & Access Keys
Terraform and GitHub Actions need to communicate with AWS to provision resources (Route53, CloudFront, S3) and invalidate caches.
1. Go to [aws.amazon.com](https://aws.amazon.com/) and create a Free Tier account.
2. Log into the AWS Management Console.
3. Search for **IAM** (Identity and Access Management).
4. Go to **Users**, click **Create User** (e.g., `github-actions-user`), and attach the `AdministratorAccess` policy (for testing only. In production, use least privilege).
5. Click on the new user, go to the **Security credentials** tab, and click **Create access key**. Select "Command Line Interface (CLI)".
6. **Save the Access Key ID and Secret Access Key** (you will need these for GitHub!).

> Note: EKS cluster creation isn't handled by this basic Terraform since it takes 20+ minutes and costs money. Ensure you have an EKS cluster running if you plan to fully deploy Part 1.

### 3. Setup the GitHub Repository & Secrets
1. Go to [GitHub](https://github.com/) and create a new, empty repository (e.g., `group7-portfolio`).
2. Push your local code to this repository (see "How to Push" below).
3. In your new GitHub repository, go to **Settings** > **Secrets and variables** > **Actions**.
4. Click **New repository secret**. Add the following secrets:
   - `AWS_ACCESS_KEY_ID`: (Paste your AWS Access Key)
   - `AWS_SECRET_ACCESS_KEY`: (Paste your AWS Secret Key)
   - `CLOUDFRONT_DISTRIBUTION_ID`: (You will get this ID *after* running Terraform for Part 2).

---

## 💻 Running the App Locally

### Phase 1: Local Raw Hosting
To run the base portfolio app locally:
```bash
docker-compose up -d
```
Visit http://localhost:8080 in your browser.

### Part 2: Local CDN Cache Simulation
To test the caching mechanism (acting as a "local CDN"):
```bash
docker-compose -f docker-compose.yml -f docker-compose.cache.yml up -d
```
Visit http://localhost:8081. This requests the app through the cache. 
- Try running `curl -I http://localhost:8081` a few times.
- Look for the `X-Proxy-Cache: HIT` or `MISS` header.

## ☁️ Deploying Infrastructure with Terraform

### DNS Settings (Part 1 - Phase 2)
1. Cd into `terraform/dns`
2. Update the variables in `variables.tf` or create a `terraform.tfvars` file with your domain name and EKS Load Balancer hostname.
3. Run `terraform init` then `terraform apply`.

### CDN Settings (Part 2 - Infra)
1. Cd into `terraform/cdn`
2. Update `variables.tf` with a globally unique S3 bucket name.
3. Run `terraform init` then `terraform apply`.
4. Copy the resulting CloudFront Distribution ID and put it in your GitHub Secrets.

---

## 🤖 CI/CD Workflows

- **Pull Requests Check**: When you open a Pull Request targeting `main`, GitHub Actions will automatically run `terraform plan` for the routing infrastructure and comment the plan on your PR.
- **Cache Invalidation**: When you push changes to `index.html` on `main` (simulating a new Docker image push), GitHub Actions will trigger AWS CLI to invalidate the CloudFront cache globally.
