
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
