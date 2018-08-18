# azure-function-key-vault

This terraform template deploy the Azure resources to illustrate an Azure Function with Managed Service Identity activated, and an Azure Key Vault with an access policy for this Function App.

The template deploys
* A Resource Group, containing all the resources
* A Storage Account
* An App Service Plan
* A Function App
* A Key Vault, with an access policy for the Function App (get secret)

# Configuration

Create a Service Principal in the Azure Active Directory, generate a key, and add it the Contributor role on the subscription where resources must be deployed.

Set variables value in the demo.tfvars file
* _subscription_id_ : Id of the subscription where the resources must be deployed
* _service_principal_id_ : Id of the Service Principal used for authentication
* _service_principal_key_ : Key generated for this Service Principal
* _tenant_id_ : Id of the tenant used for authentication
* _location_ : Location of the deployed resources
* _prefix_ : resources name prefix

# Usage

    Terraform init
Download the AzureRM provider

    Terraform plan -var-file=demo.tfvars
Create an execution plan. Can be used to see what actions Terraform will perform

    Terraform apply -var-file=demo.tfvars
Deploy resources

    Terraform destroy -var-file=demo.tfvars
Remove resources 

# Create an Azure Function

Add an access policy to the key vault created, with right to create secret, for your account.
Add a secret in the vault.

Create a Function in the Function App created by the template, using Powershell Language.
Paste the code of the GetSecretFromVault.ps1 file, and replace the secret name variable in the code.

Run the function, and the secret value is displayed in logs (#security #bestpractice)
