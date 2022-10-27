# Reference data Module (RDM) Deployment 

This document explain how to deploy the RDM component in the World Cereal context.

## Index

- [1. Requirements](#requirements)
- [2. Init](#init)
- [3. Postgresql-Ha](#postgresql-ha)
- [4. Pgadmin](#pgadmin)
- [5. jobdbmigrate](#jobdbmigrate)
- [6. jobrefdbupdate](#jobrefdbupdate)
- [7. rdmapi](#rdmapi)
- [8. rdmui](#rdmui)
- [9. Ingresses](#ingresses)


## Requirements

- Worldcereal cluster is deployed.
- Namespace rdm already exists in Worldcereal cluster.
- The secret aws-registry (image pull secret) is set for rdm namespace.

## Init
To deploy the rdm component, the first action is to set all parameters in the `export-env.sh` file.
All variable regarding S3 *MUST* be setted because it's used to generate rdm-s3 secret that is mounted in the backend pods to communicate with S3 storage.

| Name                      | Description                                     |
|---------------------------|-------------------------------------------------|
| CS_REGISTRY               | Imgage registry address to pull image from.     |
| HOSTNAME                  | Current domain name.                            |
| POSTGRESQL_CHART_VERSION  | Chart version for postgresql-ha.                |
| NGINX_CHART_VERSION       | Chart version for Nginx.                        |
| PGADMIN_CHART_VERSION     | Chart version for Pgadmin.                      |
| S3_ACCESS_KEY             | S3 access key for accessing refrence data from. |
| S3_SECRET                 | S3 secret for accessing refrence data from.     |
| S3_REGION                 | S3 region                                       |
| S3_SERVICE_NAME           | S3 service                                      |
| S3_BUCKET_URL             | S3 bucket url (used in rdmdbmigrate job)        |

When all variable are set, you can go at root repository level and run
`source export-env.sh && make init`.
This step is going to add helm repository to your local helm en play the script `sysinit.sh`.

This script is going to create all secret in the rdm namespace.

| Name                      | Description                                      |
|---------------------------|--------------------------------------------------|
| rdm-db                    | Generate credentials for postgresql-ha helm chart|
| rdm-conn-string-db        | Generate postgresql connection string for rdmapi |
| pgadmin                   | Generate password for pgadmin UI                 |
| rdm-S3                    | Generate S3 credential for rdmapi S3 connection  |

**NB: When database is recreated/redpeloyed, all the pods must be redeployed, because each pods updates the structure of the databases**

## Postgresql-Ha
All databases from the RDM context stored in postgresql-HA.
All the passwords have been generated in `sys-init.sh` step.

To deploy it:
```
make pgsql
```

## Pgadmin
Pgadmin is used as UI interface to manipulate postgresql DBs. 
The password have been generated in `sys-init.sh` step.
The ingress has to be created from the [worldcereal repository](https://github.com/WorldCereal/ewoc_platform#reference-data-module-rdm.)  

To deploy it:
```
make pgsql
```

## jobdbmigrate
Play the following command to run the job:
```
make jobdbmigrate
```
This job initialize the three databases, ewocmaster referencedb communitydb.
It uses the S3_BUCKET_URL to pull repository data from s3.


## jobrefdbupdate
Once the jobdbmigrate is completed, run :
```
make jobrefdbupdate
```
This jobs is probably take 1 or 2 hours to be completed.
It is used to initialize reference data module by creating DBs in the postgresql pods.

## rdmapi
Create back end pods : 
```
make rdmapi
```
Thoses pods mounts secrets in order to be able to connect to pgsql and S3 buckets.
It also use a emptydir volume in order to handle uploaded files by users (files are deleted when treatment is done by the container).

## rdmui
Create front end pods : 
```
make rdmui
```

## Ingresses
Once all pods are deployed, go to the [worldcereal repository](https://github.com/WorldCereal/ewoc_platform#reference-data-module-rdm.). Set clients secrets for rdm and rdmapi clients,
copy the clients secrets to export-env.sh (the one from worldcereal repo) then finally run

```
make rdm
```

This is going to create all kong route for RDM components.
