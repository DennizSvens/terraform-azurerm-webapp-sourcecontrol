
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.55.0"
    }
  }
}

variable "github_auth_token" {
  type        = string
  description = "Github Auth Token from Github > Developer Settings > Personal Access Tokens > Tokens Classic (needs to have repo permission)"
}

resource "azurerm_resource_group" "webapp-rg" {
  name     = "webapp-rg"
  location = "westeurope"
}

resource "azurerm_service_plan" "appservice-plan" {
  name                = "appservice-plan"
  resource_group_name = azurerm_resource_group.webapp-rg.name
  location            = "westeurope"
  os_type             = "Linux"
  sku_name            = "P1v3"
}

resource "azurerm_linux_web_app" "linux-web-app" {
  name                = "linux-web-app"
  resource_group_name = azurerm_resource_group.webapp-rg.name
  location            = "westeurope"
  service_plan_id     = azurerm_service_plan.appservice-plan.id
  site_config {
    application_stack {
      php_version = "8.2" # Change to appropiate application and version
    }
  }
}

resource "azurerm_app_service_source_control" "source_control" {
  app_id                 = azurerm_linux_web_app.linux-web-app.id
  repo_url               = "https://github.com/username/repo"
  branch                 = "main"
  use_manual_integration = true
}

resource "azurerm_source_control_token" "source_control_token" {
  type         = "GitHub"
  token        = var.github_auth_token
  token_secret = var.github_auth_token
}
