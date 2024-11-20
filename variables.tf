variable "organization_name" {
  type        = string
  description = "Name of the TFE organization to create the workspace in"
}

variable "github_app_installation_id" {
  type        = number
  description = "GitHub App installation ID"
}

variable "github_organization_name" {
  type        = string
  description = "GitHub organization name"
}

variable "github_tfe_repository_name" {
  type        = string
  default     = "terraform-tfe"
  description = "GitHub repository name without the organization"
}