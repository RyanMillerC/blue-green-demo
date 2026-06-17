FRONTEND_IMAGE          = quay.io/ryanmillerc/demo-frontend:latest
FRONTEND_CONTAINER      = demo-frontend
FRONTEND_LOCALHOST_PORT = 8080

BACKEND_IMAGE           = quay.io/ryanmillerc/demo-backend:latest
BACKEND_CONTAINER       = demo-backend
BACKEND_LOCALHOST_PORT  = 8081

DEV_NAMESPACE           = $(shell oc project -q)
DEV_MANIFESTS_DIR       = dev-manifests


##@ General

.PHONY: help
help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Local Development:"
	@echo "  build              Build both images"
	@echo "  build-backend      Build the backend image"
	@echo "  build-frontend     Build the frontend image"
	@echo "  push               Push both images"
	@echo "  push-backend       Push the backend image"
	@echo "  push-frontend      Push the frontend image"
	@echo "  run-backend        Start the backend container"
	@echo "  run-frontend       Start the frontend container"
	@echo "  clean              Remove both images"
	@echo "  compose-up         Start compose stack (frontend + backend)"
	@echo "  compose-down       Stop compose stack"
	@echo ""
	@echo "Helm:"
	@echo "  deploy             Deploy the Helm chart"
	@echo "  undeploy           Uninstall the Helm chart"
	@echo "  template           Render the Helm chart templates"
	@echo ""
	@echo "DevSpaces:"
	@echo "  dev-setup          Apply dev manifests to current OpenShift project"
	@echo "  dev-teardown       Delete dev manifests from current OpenShift project"
	@echo "  dev-build          Build both images in OpenShift from local source"
	@echo "  dev-build-backend  Build backend image in OpenShift from local source"
	@echo "  dev-build-frontend Build frontend image in OpenShift from local source"
	@echo "  dev-urls           Print dev route URLs"


##@ Local Development

.PHONY: build
build: build-backend build-frontend

.PHONY: build-backend
build-backend:
	docker build -f ./backend/Containerfile -t $(BACKEND_IMAGE) ./backend

.PHONY: build-frontend
build-frontend:
	docker build -f ./frontend/Containerfile -t $(FRONTEND_IMAGE) ./frontend

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

.PHONY: clean
clean:
	docker rmi $(BACKEND_IMAGE) $(FRONTEND_IMAGE)

.PHONY: compose-up
compose-up:
	docker compose up --build

.PHONY: compose-down
compose-down:
	docker compose down


##@ Helm

.PHONY: deploy
deploy:
	helm upgrade --install demo ./deploy

.PHONY: undeploy
undeploy:
	helm uninstall blue-green-demo

.PHONY: template
template:
	helm template demo ./deploy


##@ DevSpaces

.PHONY: dev-setup
dev-setup:
	sed "s/<your-namespace>/$(DEV_NAMESPACE)/g" $(DEV_MANIFESTS_DIR)/deployments.yaml | oc apply -f $(DEV_MANIFESTS_DIR)/imagestreams.yaml -f $(DEV_MANIFESTS_DIR)/buildconfigs.yaml -f $(DEV_MANIFESTS_DIR)/services.yaml -f $(DEV_MANIFESTS_DIR)/routes.yaml -f -

.PHONY: dev-teardown
dev-teardown:
	oc delete -f $(DEV_MANIFESTS_DIR)/imagestreams.yaml -f $(DEV_MANIFESTS_DIR)/buildconfigs.yaml -f $(DEV_MANIFESTS_DIR)/services.yaml -f $(DEV_MANIFESTS_DIR)/routes.yaml
	sed "s/<your-namespace>/$(DEV_NAMESPACE)/g" $(DEV_MANIFESTS_DIR)/deployments.yaml | oc delete -f -

.PHONY: dev-build
dev-build: dev-build-backend dev-build-frontend

.PHONY: dev-build-backend
dev-build-backend:
	oc start-build backend-dev --from-dir=. --follow

.PHONY: dev-build-frontend
dev-build-frontend:
	oc start-build frontend-dev --from-dir=. --follow

.PHONY: dev-urls
dev-urls:
	@echo "frontend: http://$(shell oc get route frontend-dev -o jsonpath='{.spec.host}')"
	@echo "backend:  http://$(shell oc get route backend-dev -o jsonpath='{.spec.host}')"
