FROM debian:jessie

MAINTAINER mickael.canevet@camptocamp.com

EXPOSE 61613 61616

# Install puppet-agent
ENV RELEASE jessie
RUN apt-get update \
  && apt-get install -y curl locales-all \
  && curl -O http://apt.puppetlabs.com/puppetlabs-release-pc1-${RELEASE}.deb \
  && dpkg -i puppetlabs-release-pc1-${RELEASE}.deb \
  && rm -rf /var/lib/apt/lists/*

ENV PUPPET_AGENT_VERSION 1.3.5-1${RELEASE}
RUN apt-get update \
  && apt-get install -y puppet-agent=$PUPPET_AGENT_VERSION \
  && rm -rf /var/lib/apt/lists/*

# Install activemq
RUN apt-get update \
  && apt-get install -y activemq locales-all \
  && rm -rf /var/lib/apt/lists/*

COPY activemq.xml /etc/activemq/instances-available/main/activemq.xml

RUN cp /usr/share/doc/activemq/examples/conf/credentials.properties /etc/activemq/instances-available/main/ \
  && ln -s /etc/activemq/instances-available/main /etc/activemq/instances-enabled/main

RUN mkdir /var/run/activemq/ \
  && chown activemq /var/run/activemq/ /var/lib/activemq/data

RUN apt-get update \
  && apt-get install -y net-tools \
  && rm -rf /var/lib/apt/lists/*

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
