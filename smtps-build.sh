#!/bin/bash
docker build --build-arg SERVICE=postfix -t pcifarelli/mailservice-smtps .
