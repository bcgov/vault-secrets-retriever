# vault-secrets-retriever
Use initContainer to get vault access wrapped token and envconsul in application to retrieve secrets for application

# inital setup for secrets
set secrets in the project of the namespace to hold role id and broker JWT

# Images for containers
initContainer- get vault wrap access token
```
image for test: https://artifacts.developer.gov.bc.ca/artifactory/cc20-gen-docker-local/vault-token-retrieve:test
image for prod: https://artifacts.developer.gov.bc.ca/artifactory/cc20-gen-docker-local/vault-token-retrieve:latest
```
Container- sample NestJS application use envconsul to access vault for secrets
```
image for test: https://artifacts.developer.gov.bc.ca/artifactory/cc20-gen-docker-local/nest-app:test
image for prod: https://artifacts.developer.gov.bc.ca/artifactory/cc20-gen-docker-local/nest-app:latest
```
# Helm chart deployment
use Helm Chart to install/uninstall pod in openshift
```
helm install vault-demo webapp-deployment/
helm uninstall vault-demo
```