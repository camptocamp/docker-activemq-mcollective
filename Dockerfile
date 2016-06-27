FROM ubuntu:xenial

MAINTAINER mickael.canevet@camptocamp.com

EXPOSE 61613 61614 61616

ENV STOMP_PASSWORD marionette

# Install puppet-agent
ENV RELEASE xenial
RUN apt-get update \
  && apt-get install -y curl locales-all \
  && curl -O http://apt.puppetlabs.com/puppetlabs-release-pc1-${RELEASE}.deb \
  && dpkg -i puppetlabs-release-pc1-${RELEASE}.deb \
  && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
  && apt-get install -y puppet-agent \
  && rm -rf /var/lib/apt/lists/*

# Install activemq
RUN apt-get update \
  && apt-get install -y activemq locales-all pwgen \
  && rm -rf /var/lib/apt/lists/*

COPY activemq.xml /etc/activemq/instances-available/main/activemq.xml
RUN chown activemq.activemq /etc/activemq/instances-available/main/activemq.xml \
  /etc/activemq/instances-available/main

RUN cp /usr/share/doc/activemq/examples/conf/credentials.properties /etc/activemq/instances-available/main/ \
  && ln -s /etc/activemq/instances-available/main /etc/activemq/instances-enabled/main \
  && ln -s /var/lib/activemq/main/keystore.jks /etc/activemq/instances-available/main

RUN mkdir /var/run/activemq/ \
  && chown activemq /var/run/activemq/ /var/lib/activemq/data

USER activemq

# Configure entrypoint
COPY /docker-entrypoint.sh /
COPY /docker-entrypoint.d/* /docker-entrypoint.d/
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/bin/java", "-Xms512M", "-Xmx512M", \
  "-Dorg.apache.activemq.UseDedicatedTaskRunner=true", \
  "-Dcom.sun.management.jmxremote", \
  "-Djava.io.tmpdir=/var/lib/activemq/tmp", \
  "-Dactivemq.classpath=/etc/activemq/instances-enabled/main;", \
  "-Dactivemq.home=/usr/share/activemq", \
  "-Dactivemq.base=/var/lib/activemq/main", \
  "-Dactivemq.conf=/etc/activemq/instances-enabled/main", \
  "-Dactivemq.data=/var/lib/activemq/data", \
  "-jar", "/usr/share/activemq/bin/run.jar", "start", "xbean:activemq.xml"]
