FROM nginx

RUN apt update && apt install -y  vim iputils-ping python3 python3-pip
RUN pip3 install flask flask_httpauth bcrypt

EXPOSE 80
EXPOSE 5000

COPY 02-api-start.sh /init/
RUN chmod +x /init/02-api-start.sh
RUN mkdir /local
COPY api.py /local
COPY entrypoint.sh /entrypoint.sh
RUN mkdir -p /etc/passwords/

CMD ["/bin/bash", "/entrypoint.sh"]
