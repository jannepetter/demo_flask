IMAGE_NAME ?= flask-server
TAG ?= 0.0.0

ifneq ("$(wildcard .env)","")
	include .env
	export
endif

build:
	docker build -t $(ACR_REGISTRY)/$(IMAGE_NAME):$(TAG) .
run:
	docker run -p 5000:5000 $(ACR_REGISTRY)/$(IMAGE_NAME):$(TAG)
push:
	docker push $(ACR_REGISTRY)/$(IMAGE_NAME):$(TAG) 
pull:
	docker pull $(ACR_REGISTRY)/$(IMAGE_NAME):$(TAG) 
terrascan_prod:
	-@echo "Terrascan prod env"
	docker run --rm -v $(shell pwd)/terraform:/project tenable/terrascan scan \
	 -i terraform -t azure -d /project/prod -l error --output json

docker-clean:
	@echo "Stopping and removing all Docker containers..."
	docker container prune -f
	@echo "Removing all Docker containers..."
	docker rm -f $$(docker ps -aq) 2>/dev/null || true
	@echo "Removing all Docker images..."
	docker rmi -f $$(docker images -aq) 2>/dev/null || true
	@echo "Removing all Docker volumes..."
	docker volume prune -f
	@echo "Removing all Docker networks..."
	docker network prune -f
	@echo "Docker cleanup done."