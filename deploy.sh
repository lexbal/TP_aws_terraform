#!/bin/bash

DEST_FOLDER=GENERATED/
TEMPLATE_FOLDER=TEMPLATES/
SCRIPTS=SCRIPTS/
INFRA_NAME=group-4
CLIENT_ID=4
GIT_REPO=https://github.com/

cd GENERATED/

terraform init
terraform apply --auto-approve