#!/bin/bash

if getent hosts rancher-metadata > /dev/null ; then
  PATH=/opt/puppetlabs/bin:$PATH
  confdir=$(puppet config print confdir)

  # Generate csr_attributes.yaml
  mkdir -p "${confdir}"
  cat << EOF > ${confdir}/csr_attributes.yaml
---
custom_attributes:
  1.2.840.113549.1.9.7: '$(curl http://rancher-metadata/latest/self/service/name 2> /dev/null):$(curl http://rancher-metadata/latest/self/service/uuid 2> /dev/null)'
EOF

  # Set DNSAltNames
  if test -n "${DNS_ALT_NAMES}"; then
    puppet config set dns_alt_names $DNS_ALT_NAMES --section main
  fi

  # Get certificate
  rc=1
  while test $rc -ne 0; do
    if getent hosts puppetca > /dev/null; then
      puppet agent -t --noop --server puppetca
    else
      puppet agent -t --noop
    fi
    rc=$?
  done
fi
