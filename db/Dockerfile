FROM postgres:latest

# Any sql scripts in this folder will run in the conteiner build
COPY entrypoint.sql /docker-entrypoint-initdb.d/

EXPOSE 5432
