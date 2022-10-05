.PHONY: deploy delete 

deploy:
	helm upgrade --install rdmpgsqlha bitnami/postgresql-ha --namespace=rdm \
				--version=$(POSTGRESQL_CHART_VERSION) --values=values.yaml

delete: 
	helm delete -n rdm rdmpgsqlha