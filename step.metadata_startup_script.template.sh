#!/bin/bash -eu

mkdir -p /root/.ssh/
echo "${private_key_pem}" > /root/.ssh/id_ecdsa
chmod 0600 /root/.ssh/id_ecdsa
