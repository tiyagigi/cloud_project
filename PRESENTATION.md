# Presentation: Group 7 DevOps Portfolio

---

## Slide 1: Introduction & Objective
**Global Content Delivery & GitOps Pipeline Setup**

*   **Why we did this project:** To demonstrate a modern DevOps lifecycle. Instead of manually clicking through a cloud console (which is slow and error-prone), we built an automated pipeline using "Infrastructure as Code" (IaC). This allows us to instantly and securely deploy code changes to a global Content Delivery Network (CDN).
*   **Technologies:** Docker, Nginx, Terraform, AWS (CloudFront, S3, IAM), GitHub Actions.

---

## Slide 2: The DevOps Process Overview
**Our automated workflow from code to production:**

1.  **Develop:** We write HTML/Tailwind code locally and test it using Docker containers.
2.  **Commit & Push:** Code changes are pushed to our GitHub repository.
3.  **Continuous Integration (CI):** GitHub Actions automatically checks the code and runs a `terraform plan` to propose infrastructure changes on Pull Requests.
4.  **Continuous Delivery (CD):** Once merged to the `main` branch, GitHub Actions securely logs into AWS, applies any Terraform changes, and invalidates (clears) the CDN cache.
5.  **Serve:** Users globally receive the updated portfolio instantly from the nearest AWS CloudFront edge location.

---

## Slide 3: Step 1 - Local Containerization (Docker)
**Ensuring the app runs identically everywhere:**

Before deploying to the cloud, we built a local environment to simulate our production servers and CDN caching mechanism.
*   **Action:** We configured a `docker-compose.yml` and `docker-compose.cache.yml` to spin up two Nginx containers.
*   **Command:** `docker-compose -f docker-compose.yml -f docker-compose.cache.yml up -d`
*   **Result:** Container 1 acts as the backend origin web server (Port 8080). Container 2 acts as the proxy CDN cache layer (Port 8081).

---

## Slide 4: Step 2 - Securing the Pipeline
**Connecting GitHub to AWS safely:**

We needed GitHub Actions to deploy servers on our behalf without exposing our passwords publicly.
*   **AWS Setup:** Created a strictly scoped AWS IAM User (`github-actions-user`) with programmatic Access Keys.
*   **GitHub Setup:** Stored these keys securely under `Settings -> Secrets and variables -> Actions` (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`).
*   **Result:** Our CI/CD pipeline can now securely build AWS resources on the fly.

---

## Slide 5: Step 3 - Infrastructure as Code (Terraform)
**Automating the Cloud Infrastructure:**

Instead of manual setup, we wrote Terraform scripts to build our CDN infrastructure programmatically.
*   **The Code:** `terraform/cdn/main.tf` defines an AWS S3 Bucket (to hold files) and an AWS CloudFront Distribution (to cache files globally).
*   **The Execution:** We created a GitHub Action (`tf-apply-cdn.yml`) that logs into AWS using our secrets and automatically runs `terraform apply -auto-approve`.
*   **Result:** The entire production environment is built automatically in minutes.

---

## Slide 6: Step 4 - Continuous Integration (CI)
**Automated Pull Request Checks:**

*   **The Workflow:** `tf-plan.yml`
*   **The Process:** Whenever a developer tries to merge code into the `main` branch, a GitHub Action runs `terraform plan`.
*   **Result:** It automatically comments the proposed AWS infrastructure changes directly onto the GitHub Pull Request. This allows the team to review and approve exactly what will change in AWS before it actually happens.

---

## Slide 7: Step 5 - Continuous Delivery (CD)
**Automated Cache Invalidation:**

*   **The Workflow:** `invalidate-cache.yml`
*   **The Process:** When code is finally merged into `main`, old cache files need to be deleted so users see the new updates.
*   **Result:** GitHub Actions runs the AWS CLI command `aws cloudfront create-invalidation`. This instantly purges the old website from Edge servers globally, delivering the fresh code.

---

## Slide 8: Live Demonstration
**Proving the Caching Mechanism Works:**

To prove our local CDN proxy works just like AWS CloudFront, we can inspect the response headers.

*Command executed in PowerShell:* 
`curl.exe -I http://localhost:8081`

*Expected Output:*
```text
HTTP/1.1 200 OK
Server: nginx/1.29.6
Date: Wed, 11 Mar 2026 18:56:27 GMT 
Content-Length: 11665
X-Proxy-Cache: HIT
```
*Conclusion:* Seeing `HIT` confirms that our proxy intercepted the request, found the site already saved in its cache, and delivered it instantly without hitting our backend web server!
