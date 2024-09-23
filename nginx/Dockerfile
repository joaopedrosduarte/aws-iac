FROM nginx:stable-alpine

# Setar configuração personalziada
COPY nginx.conf /etc/nginx/conf.d

# Instalação de dependências
RUN apk update && apk upgrade && \
    apk --update add logrotate openssl bash && \
    apk add --no-cache certbot certbot-nginx

# Remover configuração padrão
RUN rm /etc/nginx/conf.d/default.conf

# Adicionar www-data
RUN adduser -D -H -u 1000 -s /bin/bash www-data -G www-data
  
# Cria diretórios para as configurações
RUN mkdir -p /etc/nginx/sites-available /etc/nginx/conf.d && \
    chown -R www-data:www-data /etc/nginx/sites-available /etc/nginx/conf.d
    
# Define o diretório de trabalho para o NGINX
WORKDIR /etc/nginx

# Inicia o NGINX quando o contêiner é executado
CMD ["nginx", "-g", "daemon off;"]
