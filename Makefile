IMAGE := registry.gitlab.com/signal9/cpp-env

.DEFAULT_GOAL := squash

.PHONY: docker
docker:
	@docker pull $(IMAGE):latest; \
    docker build --pull -t $(IMAGE) \
        --cache-from $(IMAGE):latest .

.PHONY: squash
squash: docker
	@docker-squash -t $(IMAGE):squashed \
		$(IMAGE):latest

.PHONY: push
push: squash
	@docker push $(IMAGE):squashed
