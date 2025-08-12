# Variables
IMAGE_NAME = fastapi-ocr-app
PORT = 8080

# Build Docker image
build-app:
	cd app && docker build -f Dockerfile -t $(IMAGE_NAME) .

# Run Docker container
run-app:
	docker run -it --rm -p $(PORT):8080 $(IMAGE_NAME)

# Run with live code mounting (useful for development)
dev-app:
	docker run -it --rm -v $(PWD):/app -p $(PORT):8080 $(IMAGE_NAME)

# Remove image
clean-app:
	docker rmi $(IMAGE_NAME)

# Build infrastructure
build-infra:
	cd iac/terraform && terraform init
	cd iac/terraform && terraform plan
	cd iac/terraform && terraform apply

destroy-infra:
	cd iac/terraform && terraform destroy

helm-chart:
	cd helm_charts/nginx-ingress && helm install nginx-ingress .
	cd helm_charts/model-deployment && helm install model-deployment .
	helm upgrade --install -f helm_charts/monitoring/kube-prometheus-stack.expanded.yaml kube-prometheus-stack helm_charts/monitoring/kube-prometheus-stack -n monitoring

uninstall-helm-chart:
	helm uninstall nginx-ingress
	helm uninstall model-deployment
	helm uninstall kube-prometheus-stack

set-up-gce:
	ansible-playbook -i iac/ansible/inventory iac/ansible/setup-gce/create-gce.yaml

set-up-jenkins:
	ansible-playbook -i iac/ansible/inventory iac/ansible/setup-jenkins/jenkins.yaml



