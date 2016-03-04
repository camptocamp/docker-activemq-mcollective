#!/bin/sh

PATH=/opt/puppetlabs/bin:$PATH

certname=$(puppet config print certname)
cat ~/.puppetlabs/etc/puppet/ssl/private_keys/${certname}.pem ~/.puppetlabs/etc/puppet/ssl/certs/${certname}.pem > /tmp/temp.pem

# Convert to pkcs12
openssl pkcs12 -export -in /tmp/temp.pem -out /tmp/activemq.p12 -name ${certname} -password pass:secret

# Create keystore
keytool -importkeystore -destkeystore /var/lib/activemq/main/keystore.jks -srckeystore /tmp/activemq.p12 -srcstoretype PKCS12 -alias ${certname} -deststorepass secret -srcstorepass secret
