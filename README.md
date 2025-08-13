# MLOps Demo: OCR API Deployment

<div align="center">

![MLOps Workflow](images/workflow.png)

*A production-ready MLOps pipeline demonstrating OCR API deployment with modern DevOps practices*

[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://docker.com)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io)
[![Jenkins](https://img.shields.io/badge/Jenkins-D24939?style=for-the-badge&logo=Jenkins&logoColor=white)](https://jenkins.io)
[![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com)
[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://terraform.io)

</div>

## 📌 Overview

This project demonstrates deploying an OCR (Optical Character Recognition) API to Google Kubernetes Engine (GKE).

Order of operations:

- Manual first: Build Docker image → push to registry → install NGINX Ingress → deploy Helm chart to GKE → verify API.
- Then CI/CD: Enable Jenkins pipeline to automate build, push, and deploy.

### Key Features

- FastAPI-based REST API for text extraction from images
- Containerized application with optimized Docker builds
- Kubernetes deployment with auto-scaling and high availability
- Automated CI/CD pipeline with Jenkins
- Infrastructure as Code using Terraform and Ansible
- Comprehensive monitoring and logging setup
- Production-grade security configurations

## 🛠 Technology Stack

- **API Framework**: FastAPI
- **ML Engine**: Tesseract OCR
- **Container Runtime**: Docker
- **Orchestration**: Kubernetes (GKE)
- **CI/CD**: Jenkins
- **IaC**: Terraform, Ansible
- **Monitoring**: Prometheus, Grafana
- **Ingress Controller**: NGINX

## 📁 Project Structure

```plaintext
demo_deployment/
├── app/                    # FastAPI OCR application
│   ├── main.py            # Main application code
│   ├── requirements.txt   # Python dependencies
│   └── Dockerfile         # Container configuration
├── cicd/                  # CI/CD configuration
│   ├── Jenkinsfile        # Jenkins pipeline
│   └── jenkins-admin-token.yaml
├── helm_charts/           # Kubernetes Helm charts
│   ├── model-deployment/  # OCR app deployment
│   ├── nginx-ingress/     # Ingress controller
│   ├── grafana/          # Monitoring dashboards
│   └── prometheus/       # Metrics collection
├── iac/                   # Infrastructure as Code
│   ├── terraform/        # GCP infrastructure
│   └── ansible/          # Configuration management
├── example/              # Sample test images
└── Makefile              # Build automation
```

## 🚀 Quick Start

### Prerequisites

- Docker 20.10+
- Kubernetes 1.21+
- Helm 3.x
- Google Cloud SDK (gcloud + kubectl)
- A GKE cluster (existing or created separately)
- A Docker registry (Docker Hub by default)

### Local Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/demo_deployment.git
   cd demo_deployment
   ```

2. **Build and run locally**
   ```bash
   make build-app
   make run-app
   ```

3. **Test the API**
![api](images/api_result.png)

   ```bash
   # Health check (root endpoint)
   curl http://localhost:8080/

   # OCR test
   curl -X POST "http://localhost:8080/ocr/" \
        -H "Content-Type: multipart/form-data" \
        -F "file=@example/1.jpg"
   ```

### Manual Deployment to GKE (recommended before CI/CD)

1) Authenticate and connect to your GKE cluster
```bash
# If using a service account
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/sa.json"
gcloud auth activate-service-account --key-file="$GOOGLE_APPLICATION_CREDENTIALS"

# Or login interactively
gcloud auth login

# Set project/zone and fetch cluster credentials
gcloud config set project <PROJECT_ID>
gcloud container clusters get-credentials <CLUSTER_NAME> --zone <ZONE>

# Verify
kubectl cluster-info
```

2) Build and push the Docker image
```bash
# From repository root
docker build -t <DOCKERHUB_USER>/ocr_demo:latest -f app/Dockerfile app
docker push <DOCKERHUB_USER>/ocr_demo:latest
```

3) Update the chart to use your image (optional if you use the default)
```bash
# Edit helm_charts/model-deployment/values.yaml
# image.repository: <DOCKERHUB_USER>/ocr_demo
# image.tag: latest
```

4) Install NGINX Ingress Controller (LoadBalancer)
```bash
helm upgrade --install nginx-ingress helm_charts/nginx-ingress \
  -n ingress-nginx --create-namespace

# Wait for an external IP
kubectl get svc -n ingress-nginx -w | findstr LoadBalancer
```

5) Set the Ingress host

The app ingress host is defined in `helm_charts/model-deployment/templates/nginx-ingress.yaml`.

- Replace `ocr.example.com` with your domain.
- For quick testing without DNS, use nip.io with the ingress external IP, for example: `ocr.<EXTERNAL_IP>.nip.io`.

6) Deploy the OCR API chart
```bash
helm upgrade --install model-deployment helm_charts/model-deployment \
  -n model-serving --create-namespace \
  --set image.repository=<DOCKERHUB_USER>/ocr_demo \
  --set image.tag=latest
```

7) Verify deployment
```bash
kubectl get pods -n model-serving
kubectl get svc -n model-serving
kubectl get ingress -n model-serving

# Once the ingress address resolves, open docs
echo http://<YOUR_HOST>/docs

# Test API
curl -X POST "http://<YOUR_HOST>/ocr/" -F "file=@example/1.jpg"
```

Notes:
- The service listens on container port 8080 and is exposed internally on port 30000 via the service. The ingress routes to port 30000.
- If you change the host, ensure the DNS or nip.io mapping points to the ingress LoadBalancer IP.

## 📚 Documentation

### API Endpoints

- `GET /` — Health check
- `GET /metrics` — Prometheus metrics
- `POST /ocr/` — Extract text from images
  - Accepts: multipart/form-data
  - Returns: JSON with extracted text


### Configuration
Configing host to access API on GKE at C:\Windows\System32\drivers\etc\hosts
![host](images\host.png)

### Monitoring (optional)
![monitoring](images/monitor.png)

This repository includes Helm charts for Prometheus and Grafana under `helm_charts/`. You can install them after your app is running to visualize metrics exposed at `/metrics`.

## 🔒 Security

- Container vulnerability scanning
- RBAC implementation
- Network policies
- Secrets management
- SSL/TLS encryption
- Rate limiting

## 🔧 Troubleshooting

Common issues and solutions:

1. API connection issues
   ```bash
   # Check pod status
   kubectl get pods -n model-serving
   
   # Check logs
   kubectl logs deployment/model-deployment -n model-serving
   ```

2. GKE access problems
   ```bash
   # Verify cluster access
   gcloud container clusters get-credentials <CLUSTER_NAME> --zone <ZONE>
   kubectl cluster-info
   ```

3. Ingress host not resolving
   - Confirm the nginx-ingress service has an external IP.
   - Ensure your DNS record points to that IP, or use nip.io for quick testing.
   - Verify the host in `helm_charts/model-deployment/templates/nginx-ingress.yaml` matches the domain you are using.

4. Image not updating
   - Make sure you pushed the new image tag.
   - Bump the Helm chart values `image.tag` or use `--set image.tag=<new>` during upgrade.
   - Keep image pull policy as `Always` (already set in `values.yaml`) during development.

## 🔄 CI/CD with Jenkins (after manual deployment)
![CICD](images/cicd.png)
Once manual deployment is working, enable CI/CD to automate build and deploy.

1) Docker Hub and k8s credentials in Jenkins
- Create a credential with ID `dockerhub` (Username with password/API token).
- Create Key of K8s to help Jenkins can access GKE
```
kubectl apply -f cicd\jenkins-admin-token.yaml
kubectl -n kube-system get secret jenkins-admin-token \
  -o jsonpath="{.data.token}" | base64 --decode
  ```


2) Install the following Jenkins plugins: Kubernetes, Docker, and Docker Pipeline



## 👥 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 🙏 Acknowledgments

- FastAPI team for the excellent web framework
- Tesseract OCR project
- Kubernetes community
- Jenkins and Terraform communities