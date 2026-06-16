IMAGE     = blue-green-demo
CONTAINER = blue-green-demo
PORT      = 8080

.PHONY: help
help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "  build    Build the Docker image"
	@echo "  run      Start the container (foreground)"
	@echo "  stop     Remove a stuck/lingering container"
	@echo "  clean    Remove the image"

.PHONY: build
build:
	cd ./frontend && docker build -t $(IMAGE) .

.PHONY: run
run:
	docker run --rm --name $(CONTAINER) -p $(PORT):8080 $(IMAGE)

.PHONY: clean
clean:
	docker rmi $(IMAGE)
