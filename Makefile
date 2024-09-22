run: 
	docker compose up

down:
	docker compose down

clean: 
	make down
	docker rmi project-db project-api -f

run-db:
	docker build -t dbp ./db
	docker run --name dbp-container -p 5432:5432 --env-file .env -t dbp

clean-db:
	docker rm dbp-container
	docker rmi dbp

prune:
	docker container prune -f

mobral:
	make down
	make clean
	make run
