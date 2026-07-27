terraform {
  cloud {
    # Replace with your actual Terraform Cloud organization name
    organization = "Shonca"

    workspaces {
      name = "sports-store-infrastructure"
    }
  }
}
