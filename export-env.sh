#!/bin/bash
# Do not change 
export CLUSTER_RDM_ENV_LOADED="true"

#export CS_REGISTRY=501872996718.dkr.ecr.eu-central-1.amazonaws.com
export CS_REGISTRY=643vlk6z.gra7.container-registry.ovh.net

export HOSTNAME="cloud.esa-worldcereal.org"

export POSTGRESQL_CHART_VERSION="9.4.2" # -> Postgresql 14.5.0

export NGINX_CHART_VERSION="13.2.6"

export PGADMIN_CHART_VERSION="1.12.2"

# AWS
export S3_ACCESS_KEY=""
export S3_SECRET=""
export S3_REGION=""
export S3_SERVICE_NAME=""
export S3_BUCKET_URL=""