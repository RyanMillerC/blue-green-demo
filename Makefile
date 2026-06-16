FRONTEND_IMAGE     = blue-green-demo-frontend
FRONTEND_CONTAINER = blue-green-demo-frontend
FRONTEND_PORT      = 8080

BACKEND_IMAGE      = blue-green-demo-backend
BACKEND_CONTAINER  = blue-green-demo-backend
BACKEND_PORT       = 8081


.PHONY: help
help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "  build            Build both images"
	@echo "  build-backend    Build the backend image"
	@echo "  build-frontend   Build the frontend image"
	@echo "  clean            Remove both images"
	@echo "  deploy           Deploy the Helm chart"
	@echo "  run-backend      Start the backend container"
	@echo "  run-frontend     Start the frontend container"
	@echo "  template         Render the Helm chart templates"
	@echo "  undeploy         Uninstall the Helm chart"

.PHONY: build
build: build-backend build-frontend

.PHONY: build-backend
build-backend:
	docker build -f ./backend/Containerfile -t $(BACKEND_IMAGE) ./backend

.PHONY: build-frontend
build-frontend:
	docker build -f ./frontend/Containerfile -t $(FRONTEND_IMAGE) ./frontend

.PHONY: clean
clean:
	docker rmi $(BACKEND_IMAGE) $(FRONTEND_IMAGE)

.PHONY: deploy
deploy:
	helm upgrade --install blue-green-demo ./deploy

.PHONY: run-backend
run-backend:
	docker run --rm --name $(BACKEND_CONTAINER) -p $(BACKEND_PORT):8080 $(BACKEND_IMAGE)

.PHONY: run-frontend
run-frontend:
	docker run --rm --name $(FRONTEND_CONTAINER) -p $(FRONTEND_PORT):8080 $(FRONTEND_IMAGE)

.PHONY: template
template:
	helm template blue-green-demo ./deploy

.PHONY: undeploy
undeploy:
	helm uninstall blue-green-demo

