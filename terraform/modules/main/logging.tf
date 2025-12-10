resource "google_logging_project_sink" "cloudguard_activity_logs" {
  project  = split("/", google_project.main.id)[1]
  name = "cloudguard-sink"
  destination = "pubsub.googleapis.com/${google_pubsub_topic.cloudguard_activity_logs.id}"
  filter = "LOG_ID(\"cloudaudit.googleapis.com/activity\") OR LOG_ID(\"cloudaudit.googleapis.com%2Fdata_access\") OR LOG_ID(\"cloudaudit.googleapis.com%2Fpolicy\")"
}
resource "google_logging_project_sink" "cloudguard_flow_logs" {
  project  = split("/", google_project.main.id)[1]
  name = "cloudguard-fl-sink"
  destination = "pubsub.googleapis.com/${google_pubsub_topic.cloudguard_flow_logs.id}"
  filter = "LOG_ID(\"compute.googleapis.com%2Fvpc_flows\")"
}