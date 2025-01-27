# Getting Started

### Reference Documentation

Docker commands to use
* docker compose up -d --force-recreate --build
* docker network inspect backend
* docker logs -f  bby-search
* docker compose exec -it bby-search bash
* docker buildx build --platform linux/amd64,linux/arm64 -t paam0101/product-llm --push .
* docker buildx build --platform linux/amd64,linux/arm64 -t paam0101/search-ai --push .

Swagger Documentation
* [Swagger UI for the API](http://localhost:8081/swagger-ui/index.html)
* [Swagger raw OpenAPI specification](http://localhost:8081/v3/api-docs)

For Health checkup:

* [Service health checkup URL](http://localhost:8081/actuator/health)

For Terraform
* tofu init
* tofu plan -var-file="variables/local.tfvars"
* tofu apply -var-file="variables/local.tfvars" -auto-approve
* tofu destroy -var-file="variables/local.tfvars" -auto-approve
* ./run-terraform init/plan/apply/destroy


