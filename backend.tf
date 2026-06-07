terraform {
  cloud {
    organization = "ntic-center-corp"
    workspaces {
      name = "infra-hybride"
    }
  }
}