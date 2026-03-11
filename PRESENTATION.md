# Presentation: Group 7 DevOps Portfolio

---

## Slide 1: Introduction and Objective
**Global Content Delivery & GitOps Pipeline Setup**

**Objective:**
To build and deploy a static Web Portfolio using Nginx, Dockerized locally to test Content Delivery Network (CDN) optimizations, and automated through a GitOps workflow.

**Core Technologies Used:**
- Docker / Docker Compose
- Nginx
- Terraform (Infrastructure as Code)
- AWS (S3, CloudFront, IAM)
- GitHub Actions (CI/CD)

---

## Slide 2: Application Architecture
**How the Portfolio runs locally vs. globally:**

*   **HTML/Tailwind CSS:** The portfolio itself is lightweight, rendering standard HTML and styled via Tailwind CSS for rapid UI development.
*   **Local Nginx Proxy:** To simulate global caching, a custom local Nginx proxy acts as a "CDN".
    *   Visiting `localhost:8080` hits the raw Nginx app container.
    *   Visiting `localhost:8081` hits a separate Proxy container, showing us caching header metrics (`X-Proxy-Cache` HIT or MISS).

---

## Slide 3: Infrastructure as Code (Terraform)
**Automating AWS with Terraform:**

Instead of clicking through the AWS console to set up servers and buckets, we codified our infrastructure.
*   **CDN Terraform (Part 2):**
    *   Provisions an AWS S3 Bucket to hold the website assets.
    *   Provisions an AWS CloudFront Distribution (CDN) to globally cache and serve the assets with low latency.
*   **DNS Terraform (Part 1 - Optional):**
    *   Templates laid out for mapping a custom Domain Name via AWS Route 53 to an Elastic Kubernetes Service (EKS) cluster.

---

## Slide 4: Security and Credentials
**Securing our Deployment Pipeline:**

*   **AWS IAM:** Created a dedicated, scoped `github-actions-user` user instead of using root AWS credentials.
*   **GitHub Secrets:** Injected the `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `CLOUDFRONT_DISTRIBUTION_ID` securely into GitHub.
*   *Why?* This allows GitHub's cloud servers to safely provision infrastructure and clear caches on our behalf without exposing our passwords publicly in the repository code.

---

## Slide 5: The CI/CD Pipeline (GitHub Actions)
**Automating the Development Lifecycle:**

We build complete continuous integration and delivery loops.
1.  **Pull Request Workflow (`tf-plan.yml`):**
    *   When a developer opens a Pull Request to `main`, an Action runs `terraform plan`.
    *   It automatically comments the proposed AWS infrastructure changes directly onto the PR for review before anything is actually built.
2.  **CDN Invalidation (`invalidate-cache.yml`):**
    *   When changes are merged into `main`, GitHub Actions automatically logs into AWS using our CLI credentials.
    *   It issues a `cloudfront create-invalidation` command, instantly purging old content and ensuring end-users see the newest portfolio updates.

---

## Slide 6: Summary and Project Outcomes
**End-to-End Delivery Realized:**

*   **Scalable:** The static app is fully containerized and caching is optimized.
*   **Automated:** Our infrastructure creates itself (Terraform) and our code deploys itself (GitHub Actions).
*   **Robust:** PR checks ensure bad infrastructure changes aren't merged, while secret management keeps the pipeline secure.

**Project complete!**
