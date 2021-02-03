FROM rstudio/plumber

RUN R -e "install.packages('broom')"
RUN install2.r --error \
    --deps TRUE \
	tidyverse \
	pool
	
EXPOSE 8000

#RUN apt-get install -y libpq-dev
#RUN R -e "install.packages('RPostgreSQL')"


#CMD ["/home/app/plumber.R"]

