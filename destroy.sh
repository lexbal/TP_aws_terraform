#!/bin/bash

DEST_FOLDER=GENERATED/

cd ${DEST_FOLDER}

terraform init
terraform apply -destroy