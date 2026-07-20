.PHONY: test serve migrate docker-up docker-down

test:
	bin/rails test

serve:
	bin/rails server -b 127.0.0.1 -p 8012

migrate:
	bin/rails db:migrate

docker-up:
	docker compose up --build

docker-down:
	docker compose down
