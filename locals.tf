locals {
  project = {
    "tf-project" = {
      description = "My Terraform project"
    }
  }
  workspace = {
    "terraform-tfe" = {
      description         = "Automation for Terraform Enterprise using GitHub"
      execution_mode      = "remote"
      project_id          = module.project["tf-project"].id
      vcs_repo_identifier = "${var.github_organization_name}/${var.github_tfe_repository_name}"
    }
  }
}