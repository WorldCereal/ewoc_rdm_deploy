.PHONY: deploy delete 

deploy:
	#You should have previously set thoses variables in your bash context. 
	sed "s:CS_REGISTRY:$(CS_REGISTRY):;s:HOSTNAME:$(HOSTNAME):" values.tmpl > values.yaml
	helm upgrade --install rdmui bitnami/nginx --values values.yaml -n rdm

delete: 
	helm delete -n rdm rdmui