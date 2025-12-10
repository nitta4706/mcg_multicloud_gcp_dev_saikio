resource "google_compute_network" "main" {
  project = split("/", google_project.main.id)[1]

  name                    = "${local.prefix}-${var.env}-vpc"
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"

  depends_on = [google_project_service.main]
}

resource "google_compute_subnetwork" "main" {
  project = split("/", google_project.main.id)[1]

  name          = "${local.prefix}-${var.env}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.main.id

  private_ip_google_access = true
}