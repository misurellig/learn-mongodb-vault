# Learn MongoDB Vault

Some note while playing with the Hashicorp Vault learn on [Database Secrets Engine with MongoDB](https://learn.hashicorp.com/tutorials/vault/database-mongodb?in=vault/db-credentials#enable-the-database-secrets-engine).

## Requirements

  * [GNU Make](https://www.gnu.org/software/make/)
  * [jq](https://stedolan.github.io/jq/)

## Makefile

Almost everything encapsulated in a Makefile

```bash
➜ make help
help                           This help.
startup-stack                  Start Vault and MongoDB
startup-vault                  Start Vault server
vault-status                   Check Vault status
vault-enable-db-secrets        Enable Vault database secrets engine
vault-config-mongodb-secret    Configure MongoDB secrets engine
vault-mongodb-role             Create a tester role used by the MongoDB logins
request-mongodb-credentials    Request MongoDB credentials
revoke-all-tester-lease        Revoke all Vault lease for mongodb/creds/tester
startup-mongodb                Start MongoDB server
clean-all-containers           Delete all containers
```
