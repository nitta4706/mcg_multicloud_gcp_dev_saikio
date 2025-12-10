# serverless NEGを設定
resource "google_compute_region_network_endpoint_group" "wp_neg" {
  name       = "${var.main_project_id}-neg"
  project    = var.main_project_id
  region     = var.region
  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = google_cloud_run_service.wp_deploy_service.name
  }
}

# backend serviceを設定
resource "google_compute_backend_service" "wp_backend_service" {
  name         = "${var.main_project_id}-backend-service"
  project      = var.main_project_id
  protocol     = "HTTPS"
  enable_cdn   = true
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group = google_compute_region_network_endpoint_group.wp_neg.id
  }
}

# global addressを設定
resource "google_compute_global_address" "wp_lb_ip" {
  name          = "${local.prefix}-${var.env}-lb-ip"
  project       = var.main_project_id
  address_type  = "EXTERNAL"
}

# HTTP to HTTPS リダイレクトを設定するURLマップ
resource "google_compute_url_map" "http_to_https_redirect_map" {
  name    = "${local.prefix}-${var.env}-http-to-https-redirect-map"
  project = var.main_project_id

  default_url_redirect {
    https_redirect = true
    strip_query    = false
  }
}

# メインのURLマップを設定
resource "google_compute_url_map" "wp_url_map" {
  name    = "${local.prefix}-${var.env}-url-map"
  project = var.main_project_id


  # 全体のデフォルトサービスを設定（必須）
  default_service = google_compute_backend_service.wp_backend_service.self_link
}

# HTTP用のForwarding Rule
resource "google_compute_global_forwarding_rule" "wp_lb_forwarding_rule_http" {
  name                  = "${local.prefix}-${var.env}-lb-forwarding-rule-http"
  project               = var.main_project_id
  ip_address            = google_compute_global_address.wp_lb_ip.address
  load_balancing_scheme = "EXTERNAL_MANAGED"
  target                = google_compute_target_http_proxy.wp_http_proxy.self_link
  port_range            = "80"
}

# HTTPS用のForwarding Rule
resource "google_compute_global_forwarding_rule" "wp_lb_forwarding_rule_https" {
  name                  = "${local.prefix}-${var.env}-lb-forwarding-rule-https"
  project               = var.main_project_id
  ip_address            = google_compute_global_address.wp_lb_ip.address
  load_balancing_scheme = "EXTERNAL_MANAGED"
  target                = google_compute_target_https_proxy.wp_https_proxy.self_link
  port_range            = "443"
}

# HTTPプロキシを設定
resource "google_compute_target_http_proxy" "wp_http_proxy" {
  name    = "${local.prefix}-${var.env}-http-proxy"
  project = var.main_project_id
  url_map = google_compute_url_map.http_to_https_redirect_map.self_link
}

# HTTPS Proxyを設定
resource "google_compute_target_https_proxy" "wp_https_proxy" {
  name    = "${local.prefix}-${var.env}-https-proxy"
  project = var.main_project_id
  url_map = google_compute_url_map.wp_url_map.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.wp_ssl_certificate.id]
}

# マネージドSSL証明書を作成
resource "google_compute_managed_ssl_certificate" "wp_ssl_certificate" {
  name    = "${local.prefix}-${var.env}-ssl-cert"
  project = var.main_project_id
  managed {
    domains = ["${var.domain_name}"]
  }
}