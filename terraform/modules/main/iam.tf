# mcg-ope-admin
locals {
  mcg_ope_admin_role = toset([
    "roles/compute.imageUser"
  ])
}

resource "google_project_iam_member" "admin_mcg_ope_admin" {
  project  = var.prj_mcg_ope_admin
  for_each = local.mcg_ope_admin_role

  role   = each.value
  member = "group:${var.group_email}"
}
resource "google_project_iam_member" "user_mcg_ope_admin" {
  project  = var.prj_mcg_ope_admin
  for_each = local.mcg_ope_admin_role

  role   = each.value
  member = "group:${var.user_group_email}"
}

# 作成したプロジェクト
resource "google_service_account" "cloudguard" {
  project = split("/", google_project.main.id)[1]
  account_id = "cloudguard-connect"
  display_name = "CloudGuard-Connect"
}
resource "google_service_account" "cloudguard_activity_logs" {
  project = split("/", google_project.main.id)[1]
  account_id = "cloudguard-logs-authentication"
  display_name = "cloudguard-logs-authentication"
}
resource "google_service_account" "cloudguard_flow_logs" {
  project = split("/", google_project.main.id)[1]
  account_id = "cloudguard-fl-authentication"
  display_name = "cloudguard-fl-authentication"
}

locals {
  admin_project_role = toset([
    "roles/editor"
  ])
  user_project_role = toset([
    "roles/editor"
  ])
  cloudguard_role = toset([
    "roles/viewer",
    "roles/iam.securityReviewer",
    "roles/cloudasset.viewer"
  ])
}
resource "google_project_iam_member" "admin" {
  project  = split("/", google_project.main.id)[1]
  for_each = local.admin_project_role

  role   = each.value
  member = "group:${var.group_email}"
}
resource "google_project_iam_member" "user" {
  project  = split("/", google_project.main.id)[1]
  for_each = local.user_project_role

  role   = each.value
  member = "group:${var.user_group_email}"
}
resource "google_project_iam_member" "cloudguard" {
  project  = split("/", google_project.main.id)[1]
  for_each = local.cloudguard_role

  role   = each.value
  member = google_service_account.cloudguard.member
}

## Pub/Subトピック
resource "google_pubsub_topic_iam_member" "cloudguard_activity_logs" {
  project  = split("/", google_project.main.id)[1]
  topic = google_pubsub_topic.cloudguard_activity_logs.name
  role = "roles/pubsub.publisher"
  member = google_logging_project_sink.cloudguard_activity_logs.writer_identity
}
resource "google_pubsub_topic_iam_member" "cloudguard_flow_logs" {
  project  = split("/", google_project.main.id)[1]
  topic = google_pubsub_topic.cloudguard_flow_logs.name
  role = "roles/pubsub.publisher"
  member = google_logging_project_sink.cloudguard_flow_logs.writer_identity
}