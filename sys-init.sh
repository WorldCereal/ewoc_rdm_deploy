#!/usr/bin/env bash
set -e

source export-env.sh

# Generating DB password
dbpasswd=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
pgadminpasswd=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

# Creating/updating DB secret
kubectl create secret generic rdm-db --type=Opaque --namespace=rdm \
		--from-literal="postgresql-password=$dbpasswd" \
		--from-literal="repmgr-password=$(openssl rand -base64 32)" \
		--dry-run=client -oyaml | kubectl apply -f-

# Creating connect string for RDM 
kubectl create secret generic rdm-conn-string-db --type=Opaque --namespace=rdm \
		--from-literal="ewocmaster=Host=rdmpgsqlha-pgpool;Port=5432;database=ewocmaster;username=postgres;password=$dbpasswd;Timeout=300;CommandTimeout=150;" \
		--from-literal="referencedb=Host=rdmpgsqlha-pgpool;Port=5432;database=referencedb;username=postgres;password=$dbpasswd;Timeout=300;CommandTimeout=150;" \
		--from-literal="communitydb=Host=rdmpgsqlha-pgpool;Port=5432;database=communitydb;username=postgres;password=$dbpasswd;Timeout=300;CommandTimeout=150;" \
		--dry-run=client -oyaml | kubectl apply -f-

# Password for pgadmin
kubectl create secret generic pgadmin --type=Opaque --namespace=rdm \
		--from-literal="password=$pgadminpasswd" \
		--dry-run=client -oyaml | kubectl apply -f-

# S3 data
kubectl create secret generic rdm-s3 --type=Opaque --namespace=rdm \
		--from-literal="S3Config___AccessKey=$S3_ACCESS_KEY" \
		--from-literal="S3Config___Secret=$S3_SECRET" \
		--from-literal="S3Config___Region=$S3_REGION" \
		--from-literal="S3Config___ServiceName=$S3_SERVICE_NAME" \
		--dry-run=client -oyaml | kubectl apply -f-
