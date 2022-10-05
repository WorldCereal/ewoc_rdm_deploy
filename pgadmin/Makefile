.PHONY: deploy delete 

deploy:
	helm repo add runix https://helm.runix.net
	helm upgrade --install pgadmin runix/pgadmin4 -f values.yaml -n rdm

delete: 
	helm delete -n rdm rdmpgsqlha