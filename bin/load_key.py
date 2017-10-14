#!/usr/bin/python

import sys
import pwd
import grp
import os
from os.path import *
import base64

import boto3

client = boto3.client('kms')
encrypt_key = "alias/cert_private_key_protect"

public_key = "/ssl/certs/testaws_pcifarelli_net_fullchain.pem"
fname = "/ssl/private/testaws_pcifarelli_net_privkey.pem.encrypted"
outname   = "/ssl/private/testaws_pcifarelli_net_privkey.pem"

f = open(fname, "r")
k = f.read()

pubf = open(public_key, "r")
pubk = pubf.read()

response = client.decrypt(
    CiphertextBlob=base64.b64decode(k),
    EncryptionContext={
        'public_key': pubk
    }
)

f.close()
f = open(outname, "w")

print(response['KeyId'])
f.write(response['Plaintext'])
f.close()
os.chmod(outname, 0o600)
