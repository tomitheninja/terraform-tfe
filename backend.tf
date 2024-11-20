terraform {
  cloud {

    organization = "tomitheninja"

    workspaces {
      name = "terraform-tfe"
    }
  }
}
