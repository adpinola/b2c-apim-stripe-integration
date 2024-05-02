# Azure B2C - APIM - Stripe Integration

The following sample repository explores how to integrate [Azure API Management](https://azure.microsoft.com/es-es/products/api-management) with Azure B2C and Stripe. The goal is to allow uses access to backend services hosted in Azure and exposed through APIM and limiting the access based on Azure B2C credentials with monetization.

**The Monetization Server code and Stripe configuration was refactored from [Azure API Management - Monetization](https://github.com/microsoft/azure-api-management-monetization) example.**

## Deployment instructions

### Pre-Requisites

1. An Azure B2C Tenant with:
   - Custom Attributes: `Primary Key` and `Secondary Key`.
   - An API Connector for Token Enrichment.
   - A User Flow for Sign Up and Sign In with this configuration:
      - API Connection: `Before including application claims in token (preview)` step pointing the new Connector
      - Application Claims: Add `Primary Key` and `Secondary Key`
   - Two App registrations:
     - Frontend: `for authenticating users with user flows`. Configure the Redirect URI once the SPA is deployed from terraform
     - Backend: `for authenticating users with user flows`. Add a Scope

***The Backend Scope is required but not used in this demo, since there are no actual backend services***

2. An Azure Container Registry in the same Subscription where the infrastructure will be deployed.
3. An Service Principal with roles Contributor and User Access Administrator at Subscription level.
   - Configure a Federated Credential to allow GitHub to Authenticate so pipelines can deploy the infrastructure and push the image to the ACR
4. A Stripe account
   - You can use the test mode, make sure to save the API Key and the Public Key

5. If you want to deploy from this repository as-is, fork the repository and create the following secrets and variables in your Repository. Then you'll be able to use the available Workflows to deploy.

| Name                    | Kind     | Description                                                         |
| ----------------------- | -------- | ------------------------------------------------------------------- |
| ACR_NAME                | Variable | The name of the existing ACR to push the monetization server image  |
| ACR_RESOURCE_GROUP_NAME | Variable | The resource group of the ACR                                       |
| ARM_CLIENT_ID           | Secret   | The Client ID of the services principal created in step 3           |
| ARM_SUBSCRIPTION_ID     | Secret   | Target Subscription to deploy resources                             |
| ARM_TENANT_ID           | Secret   | Target Tenant to deploy resources                                   |
| B2C_CONFIG              | Variable | [An Object in HCL Language to describe the B2C Tenant](#b2c-config) |
| BACKEND_SCOPES          | Variable | A List in HCL Language of allowed backend Scopes                    |
| IMAGE_NAME              | Variable | The name of the monetization serve image                            |
| STRIPE_API_KEY          | Secret   | The API Key of your Stripe account                                  |
| STRIPE_PUBLIC_KEY       | Variable | The Public key of your Stripe account                               |

#### B2C CONFIG

The Variable should follow this structure:

```hcl
{
    audience    = string
    tenant_name = string
    policy_id   = string
    issuer      = string
}
```

`audience` is the Client ID of the Frontend App Registration created in [step 1](#pre-requisites).
`tenant_name` is the Name of your Azure B2C Tenant.
`policy_id` is the name of the User Flow created in [step 1](#pre-requisites).
`issuer` follows the this format: https://<tenant_name>.b2clogin.com/<tenant_id>/v2.0/

### Backend Scopes

The variable should have this format:

```hcl
[ "stringA", "StringB" ]
```

Where each string is a backend scope, as defined in [step 1](#pre-requisites).

### Deploy

Once all pre-requisites are completed, you can start by triggering the [Build and Push Monetization Server Image to ACR](./.github/workflows/build-and-push.yml) Workflow. This will push the image to the ACR. Once completed, trigger the [Terraform Plan/Apply](./.github/workflows/deploy.yml) Workflow. An issue will be created in your repository. You have to approve it to allow the deployment.

Once the infrastructure is deployed, check the Terraform outputs to for the `web_endpoint`. That is you application's entry point.