resource "google_storage_bucket" "uploads_bucket" {
  project = var.main_project_id
  name     = "${local.prefix}-${var.env}-uploads-bucket"
  location = var.region
  force_destroy = true
  
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "themes_bucket" {
  project = var.main_project_id
  name     = "${local.prefix}-${var.env}-themes-bucket"
  location = var.region
  force_destroy = true
  
  uniform_bucket_level_access = true
}

resource "google_storage_bucket" "plugins_bucket" {
  project = var.main_project_id
  name     = "${local.prefix}-${var.env}-plugins-bucket"
  location = var.region
  force_destroy = true
  
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_binding" "uploads_bucket_writer" {
  bucket = google_storage_bucket.uploads_bucket.name
  role   = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${google_service_account.cloud_run_service_account.email}"
  ]
}

resource "google_storage_bucket_iam_binding" "themes_bucket_writer" {
  bucket = google_storage_bucket.themes_bucket.name
  role   = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${google_service_account.cloud_run_service_account.email}"
  ]
}

resource "google_storage_bucket_iam_binding" "plugins_bucket_writer" {
  bucket = google_storage_bucket.plugins_bucket.name
  role   = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${google_service_account.cloud_run_service_account.email}"
  ]
}