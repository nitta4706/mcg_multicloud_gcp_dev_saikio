resource "google_pubsub_topic" "cloudguard_activity_logs" {
  project  = split("/", google_project.main.id)[1]
  name = "cloudguard-topic"
}
resource "google_pubsub_topic" "cloudguard_flow_logs" {
  project  = split("/", google_project.main.id)[1]
  name = "cloudguard-fl-topic"
}

resource "google_pubsub_subscription" "cloudguard_activity_logs" {
  project  = split("/", google_project.main.id)[1]
  name = "cloudguard-subscription"
  topic = google_pubsub_topic.cloudguard_activity_logs.id

  ack_deadline_seconds = 60

  expiration_policy {
    ttl = ""
  }

  push_config {
    push_endpoint = "https://gcp-activity-endpoint.dome9.com"
    
    oidc_token {
      audience = "dome9-gcp-logs-collector"
      service_account_email = google_service_account.cloudguard_activity_logs.email
    }
  }

  retry_policy {
    maximum_backoff = "60s"
    minimum_backoff = "10s"
  }
}
resource "google_pubsub_subscription" "cloudguard_flow_logs" {
  project  = split("/", google_project.main.id)[1]
  name = "cloudguard-fl-subscription"
  topic = google_pubsub_topic.cloudguard_flow_logs.id

  ack_deadline_seconds = 60

  expiration_policy {
    ttl = ""
  }

  push_config {
    push_endpoint = "https://gcp-flowlogs-endpoint.dome9.com"
    
    oidc_token {
      audience = "dome9-gcp-logs-collector"
      service_account_email = google_service_account.cloudguard_flow_logs.email
    }
  }

  retry_policy {
    maximum_backoff = "60s"
    minimum_backoff = "10s"
  }
}