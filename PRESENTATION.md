# Presentation: Group 7 DevOps Portfolio

---

## Slide 1: Introduction and Objective
**Global Content Delivery & GitOps Pipeline Setup**

**Why we did this project:**
The goal of this project is to demonstrate a modern DevOps lifecycle by building out a complete CI/CD pipeline and Infrastructure-as-Code (IaC) deployment for a web portfolio. Instead of manually clicking through a cloud console to set up servers, we wanted to show how to automate infrastructure creation, secure our credentials, and instantly deploy code changes to a global Content Delivery Network (CDN) using GitHub Actions.

**Core Technologies Used:**
- **Docker / Docker Compose:** For local containerization and testing.
- **Nginx:** As our web server and proxy cache.
- **Terraform (IaC):** To automate the AWS infrastructure setup.
- **AWS (S3, CloudFront, IAM):** For hosting and distributing the portfolio globally.
- **GitHub Actions (CI/CD):** For continuous integration and automated deployments.

---

## Slide 2: Application Architecture
**How the Portfolio runs locally vs. globally:**

*   **HTML/Tailwind CSS:** The portfolio itself is lightweight, rendering standard HTML and styled via Tailwind CSS for rapid UI development.
*   **Local Nginx Proxy:** To simulate global caching, a custom local Nginx proxy acts as a "CDN".
    *   Visiting `localhost:8080` hits the raw Nginx app container.
    *   Visiting `localhost:8081` hits a separate Proxy container, showing us caching metrics.

---

## Slide 3: Step-by-Step Setup
**How we built this environment:**

**Step 1: Local Docker Setup**
We containerized the portfolio to ensure it runs identically everywhere.
*Command used:* `docker-compose -f docker-compose.yml -f docker-compose.cache.yml up -d`

**Step 2: AWS Security**
We created a strict AWS IAM User (`github-actions-user`) with an Access Key inside the AWS Console, keeping our main AWS root account credentials safe.

**Step 3: GitHub Secrets**
We securely loaded the exact AWS credentials (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`) into our GitHub repository settings (`Settings -> Secrets and variables -> Actions`) so high-level GitHub automated processes can securely act on our behalf.

---

## Slide 4: Infrastructure as Code (Terraform)
**Automating AWS with Terraform:**

Instead of manual setup, we codified our infrastructure.
*   **CDN Terraform (Part 2):**
    *   Provisions an AWS S3 Bucket to hold the website assets.
    *   Provisions an AWS CloudFront Distribution (CDN) to globally cache and serve the assets.
*   *Implementation:* We created a manual trigger in GitHub Actions (`tf-apply-cdn.yml`) that authenticates to AWS via our secrets and automatically runs `terraform init` and `terraform apply -auto-approve` in a secure cloud runner.

---

## Slide 5: The CI/CD Pipeline (GitHub Actions)
**Automating the Development Lifecycle:**

We build complete continuous integration and delivery loops.
1.  **Pull Request Workflow (`tf-plan.yml`):**
    *   When a developer opens a Pull Request to `main`, an Action runs `terraform plan`.
    *   It comments the proposed AWS infrastructure changes on the PR for review before building anything.
2.  **CDN Invalidation (`invalidate-cache.yml`):**
    *   When changes are merged into `main`, GitHub Actions automatically logs into AWS using CLI credentials.
    *   It issues a `aws cloudfront create-invalidation` command, instantly purging old content from Edge servers globally and ensuring end-users see the newest portfolio updates.

---

## Slide 6: Live Demonstration
**Proving the Local Cache Works:**

To demonstrate the Content Delivery Network caching locally, we curl our proxy server to view the `X-Proxy-Cache` response header:

*Command executed in PowerShell:* 
`curl.exe -I http://localhost:8081`

**Expected Output:**
```text
HTTP/1.1 200 OK
Server: nginx/1.29.6
Date: Wed, 11 Mar 2026 18:56:27 GMT 
Content-Type: text/html
Content-Length: 11665
Connection: keep-alive
X-Proxy-Cache: HIT
```
*Result:* Seeing `HIT` confirms our Content Delivery System intercepted the request, found the site already saved in its cache, and delivered it to us instantly without triggering our backend server!

---

## Slide 7: Summary and Project Outcomes
**End-to-End Delivery Realized:**

*   **Scalable:** The static app is fully containerized and caching is optimized.
*   **Automated:** Our infrastructure creates itself (Terraform) and our code deploys itself (GitHub Actions).
*   **Secure:** PR checks ensure bad infrastructure changes aren't merged, while secret management keeps the pipeline secure.

**Project complete!**
