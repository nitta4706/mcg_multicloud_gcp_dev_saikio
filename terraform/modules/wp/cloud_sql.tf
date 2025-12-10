# Cloud SQL用の必要なIAMロールを付与
resource "google_project_iam_binding" "cloudsql_admin_binding" {
  project = var.main_project_id
  role    = "roles/cloudsql.admin"
  members = [
    "serviceAccount:${google_service_account.cloud_run_service_account.email}"
  ]
}

resource "google_project_iam_binding" "service_account_user_binding" {
  project = var.main_project_id
  role    = "roles/iam.serviceAccountUser"
  members = [
    "serviceAccount:${google_service_account.cloud_run_service_account.email}"
  ]
}

# servicenetworkのAPIを有効化
resource "google_project_service" "servicenetworking_api" {
  project = var.main_project_id
  service = "servicenetworking.googleapis.com"
  disable_on_destroy = false
}

# vpcネットワークの作成
resource "google_compute_network" "wp_vpc_network" {
  project                 = var.main_project_id
  name                    = "${local.prefix}-${var.env}-wp-vpc-network"
  auto_create_subnetworks = false

  depends_on = [google_project_service.servicenetworking_api]
}

# vpc内のsubnet作成
resource "google_compute_subnetwork" "wp_vpc_subnetwork" {
  project       = var.main_project_id
  name          = "${local.prefix}-${var.env}-wp-subnetwork"
  ip_cidr_range = "10.0.0.0/16"
  region        = var.region
  network       = google_compute_network.wp_vpc_network.id

  depends_on = [google_compute_network.wp_vpc_network]
}

# VPCピアリング接続
resource "google_compute_global_address" "private_ip_address_range" {
  project       = var.main_project_id
  name          = "${local.prefix}-${var.env}-private-ip-address-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.wp_vpc_network.id

  depends_on = [google_compute_network.wp_vpc_network]
}

# ペアリングの接続のためのconnection
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.wp_vpc_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address_range.name]

  depends_on = [
    google_project_service.servicenetworking_api,
    google_compute_global_address.private_ip_address_range
  ]
}

# Cloud SQL のインスタンス作成
resource "google_sql_database_instance" "wp_cloud_sql" {
  name             = "${local.prefix}-${var.env}-sql-database-instance"
  database_version = "MYSQL_8_0_31"
  region           = var.region
  project          = var.main_project_id

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.wp_vpc_network.self_link
    }
  }

  depends_on = [google_service_networking_connection.private_vpc_connection]
}

# Cloud SQL データベースの作成
resource "google_sql_database" "wp_sql_database" {
  project  = var.main_project_id
  name     = "${local.prefix}-${var.env}-sql-db"
  instance = google_sql_database_instance.wp_cloud_sql.name
  charset  = "UTF8"
  collation = "UTF8_UNICODE_CI"

  depends_on = [google_sql_database_instance.wp_cloud_sql]
}

# Cloud SQL ユーザーの作成
resource "google_sql_user" "wp_sql_user" {
  project  = google_sql_database_instance.wp_cloud_sql.project
  name     = "${local.prefix}-${var.env}-sql-user"
  instance = google_sql_database_instance.wp_cloud_sql.name
  password = "abcd"
  host     = "%"
  
  depends_on = [google_sql_database.wp_sql_database]
}