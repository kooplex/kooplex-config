FROM rocker/shiny-verse:latest

RUN R -e "install.packages(c('shinydashboard','plotly','ggplot2','DT','rsconnect'),repos='http://cran.us.r-project.org')"

COPY etc/shiny-customized.config-template /etc/shiny-server/shiny-server.conf
#ADD index.html /srv/shiny-server/index.html

#RUN adduser --no-create-home --uid 989 --disabled-password --home /srv shiny
RUN usermod --uid 989 -d /srv/report/ shiny
#RUN usermod --uid 989 -d /srv/shiny-server/ shiny

#USER shiny
RUN mv /opt/shiny-server/ext/node/bin/shiny-server /opt/shiny-server/ext/node/bin/shiny-server_
RUN echo "#!/bin/bash" > /opt/shiny-server/ext/node/bin/shiny-server
RUN echo "su shiny -c \"/opt/shiny-server/ext/node/bin/shiny-server_ \$@\" " >> /opt/shiny-server/ext/node/bin/shiny-server
RUN chmod a+x /opt/shiny-server/ext/node/bin/shiny-server 
RUN chown shiny /var/log/shiny-server
RUN chown shiny /var/lib/shiny-server
WORKDIR /srv/report


