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

# Use the public key as the Encryption Context - prevents replacement of the encrypted key in git
public_key = "public_certs/testaws_pcifarelli_net_fullchain.pem"
fname   = "private/testaws_pcifarelli_net_privkey.pem"
outname = "private/testaws_pcifarelli_net_privkey.pem.encrypted"

f = open(fname, "r")
k = f.read()
f.close()

pubf = open(public_key, "r")
pubk = pubf.read()
pubf.close()

response = client.encrypt(
    KeyId=encrypt_key,
    Plaintext=k,
    EncryptionContext={
        'public_key': pubk
    }
)

f = open(outname, "w")
print(response['KeyId'])
f.write(base64.b64encode(response['CiphertextBlob']))
f.close()
os.remove(fname)
