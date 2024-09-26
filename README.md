# Projeto Cloud

Consistem em provisionar uma estrutura que suporte e sirva uma aplicação feita em python (API feita com a framework FastAPI) que possua as seguintes propriedades:


* Aplicação embarcada em uma VM com um webserver intermediando a conexão da internet com a API
* Um banco de dados disponível para a aplicação consumir 
* Pipelines de CI e CD
* Possibilidades de troubleshooting da aplicação

### Pre requisítos

* Estar em uma máquina Linux ou Unix
* gnu tools e gcc
* PSQL ou postegresSQL Docker
* AWS CLI
* Terraform
* git configurado

## Ambiente de Dev

Para começar, você precisa ter o repositório em sua máquina, o mais fácil seria clonar o repositório com os próprios comandos git ou baixando pela UI 

```shell
git clone git@github.com:joaopedrosduarte/aws-iac.git
```

No ambiente de dev você consegue tanto simular o ambiente de Prod como desenvolver a aplicação. Tudo através de comandos docker, ou para simplificar e aumentar a produtividade, podem ser usados os comandos make.

Para esse projeto foram escolhidos alguns deles conforme a demanda, por exemplo:

```shell
make run
```

Levantar o ambiente de desenvolvimento (DB e API) o seu equivalente

```shell
docker compose up -d --build
```

Levantar o ambiente de Prod-like

```shell 
make prod
```

```shell 
docker compose -f ./Docker-compose.prod.yml up -d --build
```

Levantar apenas o banco

```shell 
make run-db
```

```shell
docker build -t dbp ./db && \
docker run --name dbp-container -p 5432:5432 --env-file .env -t dbp
```

e mais alguns outros comandos make e seus semelhantes em docker que vou deixar de mencionar, pois são muitos. 

## Levantando a infra

Nesse Repo tem a pasta de IAC, que seria no diretorio `terraform`

Para levantar ou destruir a infra é necessário:

* Entrar na pasta da IAC com `cd terraform`
* Inicializar o backend do Terraform com `terraform init`
* Por fim aplicar as mudanças com o `terraform apply` ou `terraform apply -y`
* Ou destruir os recursos com `terraform destroy` ou `terraform destroy -y`

## Deployando a APP e setup da estrutura

No primeiro deployment da aplicação é necessário realizar alguns steps manuais, já que ainda não tenho tanta proficiência com ferramentas de setup configuração como o Ansible. 

Então, para fazer esses steps manuais, é preciso ter posse de uma key pública que lhe dê acesso ao terminal da máquina via uma conexão ssh.

Partindo do princípio que se tem acesso a uma dessas chaves, os steps manuais seriam, primeiramente copiar o .env com informações do banco. Que seguiriam esse formato

```
POSTGRES_USER=<USER>
POSTGRES_PASSWORD=<PASSWORD>
POSTGRES_DB=<DB>
ENDPOINT=<ENDPOINT_DISPONIBILIZADO_PELO_DB>
DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${ENDPOINT}/${POSTGRES_DB}
```

Sendo necessário trocar os valores pelas ocorrências reais. 

É preciso copiar também a pasta do nginx com a config personalizada, (arquivo `nginx.conf`) o `Docker-compose.prod.yml` e o script de setup do banco.

Com isso, é necessário passar os arquivos através do comando `scp` estando na raiz do projeto

```shell
scp -i <ChavePúblicaAutorizada> -r nginx .env Docker-compose.prod.yml entrypoint.sql ubuntu@<IpPublicoDaVM>:/home/ubuntu/prod/
```

Com os arquivos já enviados para a VM agora é preciso entrar na mesma por uma conexão ssh 

```shell
ssh -i <ChavePúblicaAutorizada> ubuntu@<IpPublicoDaVM>
```

Já dentro da VM começa o setup do env pela execução do script de banco com o psql

```shell
sudo psql -h <HostOuAddresDoBanco> -U <User> -d <NomeDoBanco> -f <ScriptDeDump>
```

Por fim, basta rodar o docker-compose.prod.yaml e finalizar o setup da aplicação com o comando

```shell
docker compose -f ./Docker-compose.prod.yml up -d --build
```

Finalizados esses steps os próximos deployments através da pipeline de CD serão feitos automaticamente!

#### Pipelines

As pipelines estão escritas em yaml e ficam dentro da pastas de .github/workflows 