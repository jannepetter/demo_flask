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
migrate:
	docker compose exec flask_app flask db upgrade
make_migration:
	docker compose exec flask_app flask db migrate -m "$(name)"