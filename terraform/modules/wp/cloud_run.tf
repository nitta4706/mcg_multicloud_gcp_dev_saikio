# cloud runデプロイ用サービスアカウント作成
resource "google_service_account" "cloud_run_service_account" {
  project = var.main_project_id
  account_id   = "${var.main_project_id}-runsa"
  display_name = "Cloud Run Service Account"
}

# cloud run API有効化
resource "google_project_service" "run_api" {
  project = var.main_project_id
  service = "run.googleapis.com"
  disable_on_destroy = true
}

# vpcaccess API有効化
resource "google_project_service" "vpcaccess_api" {
  project = var.main_project_id
  service = "vpcaccess.googleapis.com"
  disable_on_destroy = true
}

# artifact_registry API有効化
resource "google_project_service" "artifact_registry_api" {
  project           = var.main_project_id
  service           = "artifactregistry.googleapis.com"
  disable_on_destroy = true
}

# cloud build API有効化
resource "google_project_service" "cloud_build" {
  project = var.main_project_id
  service = "cloudbuild.googleapis.com"
  disable_on_destroy = true
}

# artifact_registryのリポジトリ作成
resource "google_artifact_registry_repository" "docker_repo" {
  project  = var.main_project_id
  repository_id = "docker-repo"
  description = "Docker repository"
  format = "docker"

  depends_on = [
    google_project_service.artifact_registry_api
  ]
}

# Cloud Run 管理者権限
resource "google_project_iam_binding" "cloud_run_service_account_binding" {
  project = var.main_project_id
  role    = "roles/run.admin"

  members = [
    "serviceAccount:${google_service_account.cloud_run_service_account.email}"
  ]
  depends_on = [
    google_service_account.cloud_run_service_account
  ]
}

# Cloud SQL Client権限のサービスアカウントへの付与
resource "google_project_iam_binding" "sql_client_binding" {
  project = var.main_project_id
  role    = "roles/cloudsql.client"
  members = [
    "serviceAccount:${google_service_account.cloud_run_service_account.email}"
  ]
  depends_on = [
    google_service_account.cloud_run_service_account
  ]
}

# VPC Connectorの作成
resource "google_vpc_access_connector" "cloud_run_vpc_connector" {
  name    = "vpc-connector"
  project = var.main_project_id
  region  = var.region
  network = google_compute_network.wp_vpc_network.name
  ip_cidr_range = "10.8.0.0/28"
  # インスタンス数の設定
  min_instances   = 2  # 最小インスタンス数
  max_instances   = 10  # 最大インスタンス数

  depends_on = [
    google_compute_network.wp_vpc_network,
    google_project_service.vpcaccess_api
  ]
}

data "google_sql_database_instance" "wp_cloud_sql" {
  name    = google_sql_database_instance.wp_cloud_sql.name
  project = var.main_project_id
}

# cloud run 作成(cloud sqlへの接続情報有り)
resource "google_cloud_run_service" "wp_deploy_service" {
  project = var.main_project_id
  name = "${local.prefix}-${var.env}-cloud-run"
  location = var.region

  template {
    metadata {
      annotations = {
        "run.googleapis.com/network-interfaces" = jsonencode([{
          network   = google_compute_network.wp_vpc_network.id
          subnetwork = google_compute_subnetwork.wp_vpc_subnetwork.id
        }])
        "run.googleapis.com/vpc-access-egress" = "private-ranges-only"
      }
    }
    spec {
      containers {
        image = var.image_url
        env {
          name  = "WORDPRESS_DB_HOST"
          value = data.google_sql_database_instance.wp_cloud_sql.private_ip_address
        }
        env {
          name = "WORDPRESS_DB_USER"
          value = "user"
        }
        env {
          name  = "WORDPRESS_DB_PASSWORD"
          value = google_sql_user.wp_sql_user.password
        }
        env {
          name  = "WORDPRESS_DB_NAME"
          value = google_sql_database.wp_sql_database.name
        }
        ports {
          name = "http1"
          container_port = 8080
        }
      }
      service_account_name = google_service_account.cloud_run_service_account.email
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
  depends_on = [
    google_project_service.run_api, 
    google_project_service.artifact_registry_api,
    google_artifact_registry_repository.docker_repo,
    google_storage_bucket.uploads_bucket,
    google_storage_bucket.themes_bucket,
    google_storage_bucket.plugins_bucket,
    google_sql_database_instance.wp_cloud_sql,
    google_sql_database.wp_sql_database,
    google_storage_bucket_iam_binding.uploads_bucket_writer,
    google_storage_bucket_iam_binding.themes_bucket_writer,
    google_storage_bucket_iam_binding.plugins_bucket_writer,
    google_sql_user.wp_sql_user,
    google_vpc_access_connector.cloud_run_vpc_connector
  ]
}

# Dockerイメージのビルド
resource "null_resource" "deploy_cloud_run" {

  provisioner "local-exec" {
    command = <<EOT

      PROJECT_ID=${var.main_project_id}

      # スクリプトディレクトリのパスを設定
      SCRIPT_DIR=../../modules/wp/script

      # Create a temporary directory for the build context
      TEMP_DIR=$(mktemp -d)
      cp -r $SCRIPT_DIR/* $TEMP_DIR/
      
      ls -al $TEMP_DIR

      # Dockerイメージのビルド
      docker build --no-cache -t custom-wordpress:latest $TEMP_DIR

      gcloud config set project $PROJECT_ID
      gcloud auth configure-docker ${var.region}-docker.pkg.dev

      # Dockerイメージをコンテナレジストリにプッシュ
      docker tag custom-wordpress:latest ${var.region}-docker.pkg.dev/$PROJECT_ID/docker-repo/custom-wordpress:latest
      docker push ${var.region}-docker.pkg.dev/$PROJECT_ID/docker-repo/custom-wordpress:latest

      # Cloud Runにデプロイ
      gcloud alpha run deploy ${local.prefix}-${var.env}-cloud-run \
        --region asia-northeast1 \
        --image ${var.region}-docker.pkg.dev/$PROJECT_ID/docker-repo/custom-wordpress:latest \
        --platform managed \
        --port 80 \
        --update-env-vars WORDPRESS_DB_HOST=${data.google_sql_database_instance.wp_cloud_sql.private_ip_address} \
        --update-env-vars WORDPRESS_DB_USER=${local.prefix}-${var.env}-sql-user \
        --update-env-vars WORDPRESS_DB_NAME=${local.prefix}-${var.env}-sql-db \
        --update-env-vars WORDPRESS_DB_PASSWORD=${google_sql_user.wp_sql_user.password} \
        --add-cloudsql-instances ${google_sql_database_instance.wp_cloud_sql.connection_name} \
        --service-account ${google_service_account.cloud_run_service_account.email} \
        --add-volume=name=gcs,type=cloud-storage,bucket=${google_storage_bucket.uploads_bucket.name},mount-options=stat-cache-capacity=10000000 \
        --add-volume-mount=volume=gcs,mount-path=/var/www/html/wp-content/uploads \
        --add-volume=name=themes,type=cloud-storage,bucket=${google_storage_bucket.themes_bucket.name},mount-options=stat-cache-capacity=10000000 \
        --add-volume-mount=volume=themes,mount-path=/var/www/html/wp-content/themes \
        --add-volume=name=plugins,type=cloud-storage,bucket=${google_storage_bucket.plugins_bucket.name},mount-options=stat-cache-capacity=10000000 \
        --add-volume-mount=volume=plugins,mount-path=/var/www/html/wp-content/plugins \
        --allow-unauthenticated

      # デプロイされたサービスのURLを取得
      SERVICE_URL=$(gcloud run services describe ${local.prefix}-${var.env}-cloud-run --platform managed --region ${var.region} --format 'value(status.url)')

      echo "Service URL: $SERVICE_URL"

      # Clean up
      rm -rf $TEMP_DIR
    EOT
  }

  depends_on = [google_cloud_run_service.wp_deploy_service]
}


output "cloud_run_service_url" {
  value = google_cloud_run_service.wp_deploy_service.status[0].url
}