.PHONY: init pgsql rdmapi rdmui pgadmin jobdbmigrate jobrefdbupdate


init:
	# Build all components for Kong
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm repo add runix https://helm.runix.net
	helm repo update
	chmod 755 sys-init.sh && ./sys-init.sh

pgsql:
	@test -n "$(CLUSTER_RDM_ENV_LOADED)" || { echo 'The env variables should be source before run this script' && exit 1; }

	helm upgrade --install rdmpgsqlha bitnami/postgresql-ha --namespace=rdm \
				--version=$(POSTGRESQL_CHART_VERSION) --values=postgresql-ha/values.yaml

pgadmin:
	@test -n "$(CLUSTER_RDM_ENV_LOADED)" || { echo 'The env variables should be source before run this script' && exit 1; }
	helm upgrade --install pgadmin runix/pgadmin4 --version=$(PGADMIN_CHART_VERSION) --values=pgadmin/values.yaml -n rdm

jobdbmigrate:
	@test -n "$(CLUSTER_RDM_ENV_LOADED)" || { echo 'The env variables should be source before run this script' && exit 1; }

	sed "s:CS_REGISTRY:$(CS_REGISTRY):;s:S3_BUCKET_URL:$(S3_BUCKET_URL):" rdmDbMigrate/job.tmpl > rdmDbMigrateJob.yaml
	kubectl apply -f rdmDbMigrateJob.yaml -n rdm

jobrefdbupdate: 
	@test -n "$(CLUSTER_RDM_ENV_LOADED)" || { echo 'The env variables should be source before run this script' && exit 1; }
	@sed "s:CS_REGISTRY:$(CS_REGISTRY):;s:S3_BUCKET_URL:$(S3_BUCKET_URL):" rdmRefDbUpdate/job.tmpl > rdmRefDbUpdate.yaml

	kubectl apply -f rdmRefDbUpdate/refdbpvc.yaml
	kubectl apply -f rdmRefDbUpdate.yaml -n rdm

rdmapi:
	@test -n "$(CLUSTER_RDM_ENV_LOADED)" || { echo 'The env variables should be source before run this script' && exit 1; }

	@sed "s:CS_REGISTRY:$(CS_REGISTRY):" rdmapi/values.tmpl >rdmapi-values.yaml
	helm upgrade --install rdmapi rdmapi/. --namespace=rdm \
			--values=rdmapi-values.yaml

rdmui:
	@test -n "$(CLUSTER_RDM_ENV_LOADED)" || { echo 'The env variables should be source before run this script' && exit 1; }
	sed "s:CS_REGISTRY:$(CS_REGISTRY):;s:HOSTNAME:$(HOSTNAME):" rdmui/values.tmpl > rdmui-values.yaml
	helm upgrade --install rdmui bitnami/nginx --version=$(NGINX_CHART_VERSION) --values rdmui-values.yaml -n rdm
