#!/bin/bash

set -e

echo "This script will bootstrap the Terraform Enterprise organization"

echo "1. Please log in to your organization admin account"
echo "https://app.terraform.io/session"
echo ""
echo "Press enter to continue"
read


echo "2. Create a new TFE organization"
echo "Don't create any projects or workspaces"
echo "https://app.terraform.io/app/organizations/new"
echo ""
echo "Enter the organization name:"
read organization_name
echo ""

if [ -z "$organization_name" ]; then
  echo "Organization name is required"
  exit 1
fi

echo "3. Please log in to your GitHub service account"
echo "https://github.com/login"
echo ""
echo "Press enter to continue"
read

echo "4. Is Terraform Cloud installed to this GitHub account? (y/N)"
echo "https://github.com/settings/installations"
read answer
echo ""
if [ "$answer" != "y" ]; then
  echo "Connect TFE to the GitHub account by starting a new workspace installation"
  echo "important: do not create the workspace, just start the installation"
  echo "1. open this link"
  echo "2. select 'Version Control Workflow'"
  echo "3. select 'GitHub App'"
  echo "4. quit after the app installation"
  echo "https://app.terraform.io/app/$organization_name/workspaces/new"
  echo ""
  echo "Press enter to continue"
  read
fi

echo "5. Go to https://github.com/settings/installations and click on 'Configure Terraform Cloud'"
echo ""
echo "Press enter to continue"
read

echo "6. Enter the installation ID from the URL:"
read installation_id
echo ""

if [ -z "$installation_id" ]; then
  echo "Installation ID is required"
  exit 1
fi

echo "7. Enter the name of your GitHub organization or user:"
read github_organization_name
echo ""

if [ -z "$github_organization_name" ]; then
  echo "GitHub organization name is required"
  exit 1
fi

echo "8. Updating backend.tf with the GitHub organization name"
sed --in-place "s/organization = .*/organization = \"$organization_name\"/" backend.tf
echo "Please commit and push these changes"
echo ""
echo "Press enter to continue"
read

echo "9. Updating backend.tf with a temporary workspace name"
sed --in-place "s/name = \"terraform-tfe\"/name = \"local-bootstrap\"/" backend.tf
echo "Please do NOT commit these changes"
echo ""

echo "10. Please create an API token for the organization owner"
echo "https://app.terraform.io/app/settings/tokens"
echo ""
echo "Enter the token:"
read tfe_token
echo ""

if [ -z "$tfe_token" ]; then
  echo "Token is required"
  exit 1
fi

echo "11. Initializing Terraform"
TF_TOKEN_APP_TERRAFORM_IO=$tfe_token terraform init
echo ""

echo "12. Please create a new variable set here:"
echo "https://app.terraform.io/app/$organization_name/settings/varsets/new"
echo "Set any name"
echo "Select local-bootstrap as workspace"
echo ""
echo "Add environment variable, sensitive TFE_TOKEN=$tfe_token"
echo "Add terraform variable organization_name=$organization_name"
echo "Add terraform variable github_organization_name=$github_organization_name"
echo "Add terraform variable github_app_installation_id=$installation_id"
echo ""
echo "Create the variable set"
echo ""
echo "Press enter to continue"
read

echo "13. Executing Terraform in the local-bootstrap workspace"
TF_TOKEN_APP_TERRAFORM_IO=$tfe_token terraform apply
TF_TOKEN_APP_TERRAFORM_IO=$tfe_token terraform state pull > bootstrap.tfstate

echo "14. Please apply your variable set on the terraform-tfe workspace"
echo "https://app.terraform.io/app/$organization_name/workspaces/terraform-tfe/variables"
echo ""
echo "Press enter to continue"
read

echo "15. Restoring your backend.tf workspace name"
sed --in-place "s/name = \"local-bootstrap\"/name = \"terraform-tfe\"/" backend.tf
echo ""
echo "Press enter to continue"
read

echo "16. Reinitializing Terraform with the new workspace"
TF_TOKEN_APP_TERRAFORM_IO=$tfe_token terraform init
echo ""
echo "Press enter to continue"
read

echo "16. Uploading the local state to the remote state"
TF_TOKEN_APP_TERRAFORM_IO=$tfe_token TFE_TOKEN=$tfe_token terraform state push boostrap.tfstate

echo "Organization bootstrapped successfully"
echo "Please continue by setting the variables for each workspace"
echo "Bye!"

exit 0