FRONTEND_IMAGE          = quay.io/ryanmillerc/demo-frontend:latest
FRONTEND_CONTAINER      = demo-frontend
FRONTEND_LOCALHOST_PORT = 8080

BACKEND_IMAGE           = quay.io/ryanmillerc/demo-backend:latest
BACKEND_CONTAINER       = demo-backend
BACKEND_LOCALHOST_PORT  = 8081


.PHONY: help
help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "  build            Build both images"
	@echo "  build-backend    Build the backend image"
	@echo "  build-frontend   Build the frontend image"
	@echo "  clean            Remove both images"
	@echo "  compose-down     Stop compose stack"
	@echo "  compose-up       Start compose stack (frontend + backend)"
	@echo "  deploy           Deploy the Helm chart"
	@echo "  push             Push both images"
	@echo "  push-backend     Push the backend image"
	@echo "  push-frontend    Push the frontend image"
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

.PHONY: compose-down
compose-down:
	docker compose down

.PHONY: compose-up
compose-up:
	docker compose up --build

.PHONY: deploy
deploy:
	helm upgrade --install demo ./deploy

.PHONY: push
push: push-backend push-frontend

.PHONY: push-backend
push-backend:
	docker push $(BACKEND_IMAGE)

.PHONY: push-frontend
push-frontend:
	docker push $(FRONTEND_IMAGE)

.PHONY: run-backend
run-backend:
	docker run --rm --name $(BACKEND_CONTAINER) -p $(BACKEND_LOCALHOST_PORT):8080 $(BACKEND_IMAGE)

.PHONY: run-frontend
run-frontend:
	docker run --rm --name $(FRONTEND_CONTAINER) -p $(FRONTEND_LOCALHOST_PORT):8080 $(FRONTEND_IMAGE)

.PHONY: template
template:
	helm template demo ./deploy

.PHONY: undeploy
undeploy:
	helm uninstall blue-green-demo
