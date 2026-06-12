IMAGE     = muppets-demo
CONTAINER = muppets-demo
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
	docker build -t $(IMAGE) .

.PHONY: run
run:
	docker run --rm --name $(CONTAINER) -p $(PORT):5000 $(IMAGE)

.PHONY: clean
clean:
	docker rmi $(IMAGE)
