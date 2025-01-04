#!/bin/bash

if [[ $UID -ge 10000 ]]; then
    GID=$(id -g)
    sed -e "s/^postgres:x:[^:]*:[^:]*:/postgres:x:$UID:$GID:/" /etc/passwd > /tmp/passwd
    cat /tmp/passwd > /etc/passwd
    rm /tmp/passwd
fi

cat > /home/postgres/patroni.yml <<__EOF__
bootstrap:
  dcs:
    postgresql:
      parameters:
        max_connections: 100
        shared_buffers: 16MB
        ssl: 'on'
        ssl_ca_file: /etc/ssl/certs/ssl-cert-snakeoil.pem
        ssl_cert_file: /etc/ssl/certs/ssl-cert-snakeoil.pem
        ssl_key_file: /etc/ssl/private/ssl-cert-snakeoil.key
        citus.node_conninfo: 'sslrootcert=/etc/ssl/certs/ssl-cert-snakeoil.pem sslkey=/etc/ssl/private/ssl-cert-snakeoil.key sslcert=/etc/ssl/certs/ssl-cert-snakeoil.pem sslmode=verify-ca'
      parameters:
        max_connections: 100
        shared_buffers: 16MB
        ssl: 'on'
        ssl_ca_file: /etc/ssl/certs/ssl-cert-snakeoil.pem
        ssl_cert_file: /etc/ssl/certs/ssl-cert-snakeoil.pem
        ssl_key_file: /etc/ssl/private/ssl-cert-snakeoil.key
        citus.node_conninfo: 'sslrootcert=/etc/ssl/certs/ssl-cert-snakeoil.pem sslkey=/etc/ssl/private/ssl-cert-snakeoil.key sslcert=/etc/ssl/certs/ssl-cert-snakeoil.pem sslmode=verify-ca'
      use_pg_rewind: true
      pg_hba:
      - local all all trust
      - local all all trust
      - hostssl all all all md5 clientcert=verify-ca
      - hostssl replication ${PATRONI_REPLICATION_USERNAME} all md5 clientcert=verify-ca
      - hostssl replication ${PATRONI_REPLICATION_USERNAME} all md5 clientcert=verify-ca
  initdb:
  - auth-host: md5
  - auth-local: trust
  - encoding: UTF8
  - locale: en_US.UTF-8
  - data-checksums
restapi:
  connect_address: '${PATRONI_KUBERNETES_POD_IP}:8008'
postgresql:
  basebackup:
    checkpoint: fast
  basebackup:
    checkpoint: fast
  connect_address: '${PATRONI_KUBERNETES_POD_IP}:5432'
  authentication:
    superuser:
      password: '${PATRONI_SUPERUSER_PASSWORD}'
    replication:
      password: '${PATRONI_REPLICATION_PASSWORD}'
__EOF__

unset PATRONI_SUPERUSER_PASSWORD PATRONI_REPLICATION_PASSWORD

exec /usr/bin/python3 /usr/local/bin/patroni /home/postgres/patroni.yml
