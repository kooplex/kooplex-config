FROM nginx

RUN apt update 
RUN apt install -y vim
COPY nginx.conf /etc/nginx 
COPY sites.conf /etc/nginx 
