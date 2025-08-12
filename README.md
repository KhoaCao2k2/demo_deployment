# MLOps Demo Deployment - OCR API

<div align="center">

![MLOps Workflow](images/workflow.png)

*A comprehensive MLOps demo showcasing the deployment of an OCR (Optical Character Recognition) API using modern DevOps practices*

[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://docker.com)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io)
[![Jenkins](https://img.shields.io/badge/Jenkins-D24939?style=for-the-badge&logo=Jenkins&logoColor=white)](https://jenkins.io)
[![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com)
[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://terraform.io)

</div>

## 🚀 Project Overview

This project demonstrates a complete MLOps workflow for deploying a FastAPI-based OCR service that extracts text from images using Tesseract. The deployment includes:

- **FastAPI OCR Application**: REST API for text extraction from images
- **Docker Containerization**: Containerized application with proper dependencies
- **Kubernetes Deployment**: Helm charts for orchestration
- **CI/CD Pipeline**: Jenkins-based automated deployment
- **Infrastructure as Code**: Terraform and Ansible for infrastructure management
- **Ingress Controller**: Nginx ingress for external access

## 📁 Project Structure

```
demo_deployment/
├── 📁 app/                    # FastAPI OCR application
│   ├── main.py               # Main application code
│   ├── requirements.txt      # Python dependencies
│   └── Dockerfile           # Container configuration
├── 📁 cicd/                  # CI/CD configuration
│   └── Jenkinsfile          # Jenkins pipeline
├── 📁 helm_charts/           # Kubernetes Helm charts
│   ├── model-deployment/    # OCR app deployment
│   └── nginx-ingress/       # Ingress controller
├── 📁 iac/                   # Infrastructure as Code
│   ├── terraform/           # Terraform configurations
│   └── ansible/             # Ansible playbooks
├── 📁 images/                # Project images and diagrams
├── 📁 example/               # Sample images for testing
└── Makefile                 # Build and deployment commands
```

## 🛠️ Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Kubernetes cluster](https://kubernetes.io/docs/setup/) (GKE, EKS, or local like Minikube)
- [Helm 3.x](https://helm.sh/docs/intro/install/)
- [Terraform](https://www.terraform.io/downloads)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- [Jenkins](https://www.jenkins.io/doc/book/installing/) (for CI/CD)
- [kubectl](https://kubernetes.io/docs/tasks/tools/) configured

## 🚀 Quick Start

### 1. Local Development

```bash
# Build and run the application locally
make build-app
make run-app

# Or run in development mode with live code mounting
make dev-app
```

The API will be available at `http://localhost:8080`

### 2. API Usage

#### Health Check
```bash
curl http://localhost:8080/
```

#### Extract Text from Image
```bash
curl -X POST "http://localhost:8080/ocr/" \
     -H "accept: application/json" \
     -H "Content-Type: multipart/form-data" \
     -F "file=@example/1.jpg"
```

**Example Response:**
```json
{
  "extracted_text": "Hello World! This is sample text extracted from the image."
}
```

### 3. Kubernetes Deployment

```bash
# Deploy all components using Helm
make helm-chart

# Uninstall all components
make uninstall-helm-chart
```

### 4. Infrastructure Setup

```bash
# Deploy infrastructure using Terraform
make build-infra

# Destroy infrastructure
make destroy-infra
```

## 📋 Detailed Setup Instructions

### Application Development

The OCR API is built with FastAPI and provides the following endpoints:

- `GET /`: Health check endpoint
- `POST /ocr/`: Extract text from uploaded images

**Key Features:**
- Supports multiple image formats (JPEG, PNG, etc.)
- Uses Tesseract OCR engine
- Returns extracted text in JSON format
- Built-in API documentation at `/docs`

### Containerization

The application is containerized using Docker with the following features:

- Multi-stage build for optimized image size
- Tesseract OCR engine pre-installed
- Proper dependency management
- Health checks and proper signal handling

### Kubernetes Deployment

The project includes comprehensive Helm charts for:

1. **Model Deployment Chart** (`helm_charts/model-deployment/`)
   - Deploys the OCR API with proper scaling
   - Configures services and ingress
   - Includes resource limits and health checks

2. **Nginx Ingress** (`helm_charts/nginx-ingress/`)
   - Load balancing and SSL termination
   - Path-based routing
   - Rate limiting and security features

### CI/CD Pipeline

The Jenkins pipeline (`cicd/Jenkinsfile`) includes:

1. **Build Stage**: Docker image building and pushing to registry
2. **Deploy Stage**: Helm-based deployment to Kubernetes
3. **Test Stage**: Automated testing (placeholder for future expansion)

**Pipeline Features:**
- Automated image versioning
- Multi-environment deployment support
- Build artifact retention
- Timestamp logging

### Infrastructure as Code

#### Terraform (`iac/terraform/`)
- Google Cloud Platform infrastructure provisioning
- Kubernetes cluster setup
- Networking and security configurations
- Output variables for integration with other tools

#### Ansible (`iac/ansible/`)
- GCE instance provisioning
- Jenkins server setup and configuration
- Application deployment automation
- Configuration management

## 🔧 Configuration

### Environment Variables

The application supports the following environment variables:

- `TESSERACT_PATH`: Path to Tesseract executable (default: "tesseract")
- `PORT`: Application port (default: 8080)

### Helm Values

Customize deployments by modifying the `values.yaml` files in each Helm chart:

- Replica counts
- Resource limits
- Environment variables
- Ingress configurations

## 🧪 Testing

### Manual Testing

1. **Local Testing**:
   ```bash
   make dev-app
   curl -X POST "http://localhost:8080/ocr/" -F "file=@example/1.jpg"
   ```

2. **Kubernetes Testing**:
   ```bash
   # Get the service URL
   kubectl get svc -n model-serving
   
   # Test the API
   curl -X POST "http://<service-ip>:30000/ocr/" -F "file=@example/1.jpg"
   ```

### Automated Testing

The CI/CD pipeline includes a test stage that can be extended with:
- Unit tests for the OCR functionality
- Integration tests for the API endpoints
- Load testing for performance validation
- Security scanning

## 🔒 Security Considerations

- Container images are scanned for vulnerabilities
- Secrets are managed through Kubernetes secrets
- Network policies restrict pod-to-pod communication
- RBAC is configured for proper access control
- Ingress includes rate limiting and SSL termination

## 🚀 Scaling

The application supports horizontal scaling:

```bash
# Scale the deployment
kubectl scale deployment model-deployment --replicas=5 -n model-serving

# Or update via Helm
helm upgrade model-deployment helm_charts/model-deployment --set replicas=5 -n model-serving
```

## 🛠️ Troubleshooting

### Common Issues

1. **Tesseract not found**: Ensure the Docker image includes Tesseract installation
2. **Image processing errors**: Check supported image formats and file sizes
3. **Kubernetes deployment issues**: Verify Helm chart values and cluster resources
4. **Jenkins build failures**: 
   - Ensure Docker Hub credentials are configured in Jenkins
   - Check that the app directory is properly cloned in Jenkins workspace
   - Verify Docker build locally before running in Jenkins

### Debug Commands

```bash
# Check pod logs
kubectl logs -f deployment/model-deployment -n model-serving

# Check pod status
kubectl get pods -l app=model-deployment -n model-serving

# Check service endpoints
kubectl get endpoints model-deployment -n model-serving

# Check ingress status
kubectl get ingress -n model-serving

# Check Helm releases
helm list -n model-serving
```

## 🎯 API Documentation

Once the application is running, you can access the interactive API documentation:

- **Swagger UI**: `http://localhost:8080/docs`
- **ReDoc**: `http://localhost:8080/redoc`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

**Cao Huynh Anh Khoa**
- Email: caohuynhanhkhoa2002@gmail.com

## 🙏 Acknowledgments

- [FastAPI](https://fastapi.tiangolo.com/) for the web framework
- [Tesseract](https://github.com/tesseract-ocr/tesseract) for OCR capabilities
- [Kubernetes](https://kubernetes.io/) community for orchestration tools
- [Helm](https://helm.sh/) for package management
- [Jenkins](https://www.jenkins.io/) for CI/CD automation

---

<div align="center">

**⭐ Star this repository if you find it helpful!**

</div>