# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/data-sources/github_app_installation#finding-a-github-app-installation-by-its-installation-id
data "tfe_github_app_installation" "this" {
  installation_id = var.github_app_installation_id
}