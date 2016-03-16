#!/bin/sh

/opt/puppetlabs/puppet/bin/augtool -Ast "Xml incl /etc/activemq/instances-available/main/activemq.xml" "set //authenticationUser[#attribute/username = 'mcollective']/#attribute/password $MCOLLECTIVE_PASSWORD"
