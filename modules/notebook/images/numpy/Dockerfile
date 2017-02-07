FROM kooplex-notebook-base

MAINTAINER Laszlo Dobos <dobos@complex.elte.hu

RUN apt-get update \
	&& apt-get install -y \
		liblapack-dev \
		libblas-dev \
	&& apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN pip3 install --no-cache-dir pandas numpy scipy matplotlib

