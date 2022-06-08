export VAULT_DEV_ROOT_TOKEN_ID = vDUVE70vavZ1QnEo
export VAULT_DEV_LISTEN_ADDRESS = 0.0.0.0:8200
export VAULT_ADDR=http://127.0.0.1:8200
export MONGO_INITDB_ROOT_USERNAME = mdbadmin
export MONGO_INITDB_ROOT_PASSWORD = hQ97T9JJKZoqnFn2NXE

mongodb_host_ip := $(shell docker inspect mongodb | jq -rc '.[].NetworkSettings.IPAddress')

.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

startup-stack: startup-vault startup-mongodb ## Start Vault and MongoDB

startup-vault: ## Start Vault server
	@docker run -d \
		--name vault \
		--cap-add=IPC_LOCK \
		-e VAULT_DEV_ROOT_TOKEN_ID=$(VAULT_DEV_ROOT_TOKEN_ID) \
		-e VAULT_DEV_LISTEN_ADDRESS=$(VAULT_DEV_LISTEN_ADDRESS) \
		-p 8200:8200 \
		vault

vault-status: ## Check Vault status
	@vault status

vault-enable-db-secrets: ## Enable Vault database secrets engine
	@vault secrets enable -path=mongodb database

vault-config-mongodb-secret: ## Configure MongoDB secrets engine
	@vault write mongodb/config/mongo-test \
      plugin_name=mongodb-database-plugin \
      allowed_roles="tester" \
      connection_url="mongodb://{{username}}:{{password}}@$(mongodb_host_ip):27017/admin?tls=false" \
      username=$(MONGO_INITDB_ROOT_USERNAME) \
      password=$(MONGO_INITDB_ROOT_PASSWORD)

vault-mongodb-role: ## Create a tester role used by the MongoDB logins
	@vault write mongodb/roles/tester \
    db_name=mongo-test \
    creation_statements='{ "db": "admin", "roles": [{ "role": "readWrite" }, {"role": "read", "db": "foo"}] }' \
    default_ttl="1h" \
    max_ttl="24h"

request-mongodb-credentials: ## Request MongoDB credentials
	@vault read mongodb/creds/tester -field=password

revoke-all-tester-lease: ## Revoke all Vault lease for mongodb/creds/tester
	@vault lease revoke -prefix mongodb/creds/tester

startup-mongodb: ## Start MongoDB server
	@docker run -d \
	--name mongodb \
    -p 0.0.0.0:27017:27017 \
	-p 0.0.0.0:28017:28017 \
    --name=mongodb \
    -e MONGO_INITDB_ROOT_USERNAME=$(MONGO_INITDB_ROOT_USERNAME) \
    -e MONGO_INITDB_ROOT_PASSWORD=$(MONGO_INITDB_ROOT_PASSWORD) \
    mongo

clean-all-containers: ## Delete all containers
	@docker rm -f vault mongodb
