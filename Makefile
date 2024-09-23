run: 
	docker compose up -d --build

down:
	docker compose down -v	

prod: 
	docker compose -f ./Docker-compose.prod.yml up --build

down-prod:
	docker compose -f Docker-compose.prod.yml down -v

clean: 
	make down
	docker rmi project-db project-api -f

run-db:
	docker build -t dbp ./db
	docker run --name dbp-container -p 5432:5432 --env-file .env -t dbp

clean-db:
	docker rm dbp-container
	docker rmi dbp

run-nginx:
	docker build -t nginxp ./nginx
	docker run --name nginxp-container -p 1337:80 -t nginxp

down-nginx:
	docker rm nginxp-container
	docker rmi nginxp

prune:
	docker container prune -f

mobral:
	make down
	make clean
	make run
