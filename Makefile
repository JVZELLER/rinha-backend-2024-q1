############################
#          TESTS           #
############################

.PHONY: up
up: 
	docker-compose up -d

.PHONY: prepare
prepare:
	@mix setup

.PHONY: down
down:
	docker-compose \
		down --remove-orphans

############################
# Build and Deploy targets #
############################
# Git tag or something else
TAG = latest
REPO = jvzeller/rinha-backend-2024-q1

.PHONY: docker-image
docker-image:
	docker image build \
		--pull \
		--tag $(REPO):$(TAG) \
		--label "jvzeller.rinha" \
		.