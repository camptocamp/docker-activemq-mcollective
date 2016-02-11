FROM debian:jessie

MAINTAINER mickael.canevet@camptocamp.com

EXPOSE 61613 61616

RUN apt-get update \
  && apt-get install -y activemq locales-all \
  && rm -rf /var/lib/apt/lists/*

COPY activemq.xml /etc/activemq/instances-available/mcollective/activemq.xml

RUN ln -s /etc/activemq/instances-available/mcollective /etc/activemq/instances-enabled/mcollective
