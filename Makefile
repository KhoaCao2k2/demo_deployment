# Variables
IMAGE_NAME = fastapi-ocr-app
PORT = 8080

# Build Docker image
build:
	cd app
	docker build -f app/Dockerfile -t $(IMAGE_NAME) app

# Run Docker container
run:
	docker run -it --rm -p $(PORT):8080 $(IMAGE_NAME)

# Run with live code mounting (useful for development)
dev:
	docker run -it --rm -v $(PWD):/app -p $(PORT):8080 $(IMAGE_NAME)

# Remove image
clean:
	docker rmi $(IMAGE_NAME)

.PHONY: build run dev push clean
