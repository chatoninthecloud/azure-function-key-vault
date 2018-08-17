provider "azurerm" {
    version         = "1.12.0"
    subscription_id = "${var.subscription_id}"
    client_id       = "${var.service_principal_id}"
    client_secret   = "${var.service_principal_key}"
    tenant_id       = "${var.tenant_id}"
}


# Resource Group containing all Azure resources
resource "azurerm_resource_group" "demo_msi_rg" {
    name        = "${var.prefix}-sample-msi-rg"
    location    = "${var.location}"
}

# Storage account used by the Function App 
resource "azurerm_storage_account" "demo_function_storage" {
    name                        = "${var.prefix}msistorage"
    resource_group_name         = "${azurerm_resource_group.demo_msi_rg.name}"
    location                    = "${var.location}"
    account_tier                = "Standard"
    account_replication_type    = "GRS"
    account_kind                = "StorageV2"
}

# App Service Plan
resource "azurerm_app_service_plan" "demo_app_service_plan" {
    name                = "${var.prefix}-sample-app-service-plan"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.demo_msi_rg.name}"
    kind = "FunctionApp"

    sku {
        tier = "Dynamic"
        size = "Y1"
    }
}

# Function App
resource "azurerm_function_app" "demo_function_app" {
    name                        = "${var.prefix}-sample-func-app"
    location                    = "${var.location}"
    resource_group_name         = "${azurerm_resource_group.demo_msi_rg.name}"
    app_service_plan_id         = "${azurerm_app_service_plan.demo_app_service_plan.id}"
    storage_connection_string   = "${azurerm_storage_account.demo_function_storage.primary_connection_string}"
    https_only                  = true
    enabled                     = true
    client_affinity_enabled     = false

    app_settings = {
        key_valut_name = "${var.prefix}-sample-vault"
    }

    identity = {
        type = "SystemAssigned"
    }
}

# Key vault used to store secret used by Azure functions
resource "azurerm_key_vault" "vault" {
    name                = "${var.prefix}-sample-vault"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.demo_msi_rg.name}"

    sku {
        name = "standard"
    }

    tenant_id = "${var.tenant_id}"

    access_policy {
        tenant_id = "${azurerm_function_app.demo_function_app.identity.0.tenant_id}"
        object_id = "${azurerm_function_app.demo_function_app.identity.0.principal_id}"

        key_permissions = []

        secret_permissions = [
        "get",
        ]
    }

    enabled_for_disk_encryption = true
}
