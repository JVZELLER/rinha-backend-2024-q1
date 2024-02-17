############################
#          TESTS           #
############################

.PHONY: up
up: 
	docker compose up -d

.PHONY: prepare
prepare:
	@mix setup

.PHONY: down
down:
	docker compose \
		down --remove-orphans