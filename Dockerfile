FROM debian:buster
ENV LANG C.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL C.UTF-8
RUN apt-get update \
        && apt-get install --no-install-recommends -y swi-prolog-nox \
        && rm -rf /var/cache/apt/*
