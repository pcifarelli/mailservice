#!/bin/bash
docker build --build-arg SERVICE=dovecot -t pcifarelli/mailservice-imaps .
