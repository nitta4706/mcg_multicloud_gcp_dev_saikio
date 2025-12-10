resource "google_folder" "env" {
  display_name = var.env
  parent       = var.folder_id
}

resource "google_project" "main" {
  name                = "${local.prefix}-${var.env}"
  project_id          = "${local.prefix}-${var.env}"
  folder_id           = google_folder.env.name
  billing_account     = var.billing_account_id
  auto_create_network = false

  labels = {
    type = "mcg"
  }
}

output "project_id" {
  value = google_project.main.project_id
}