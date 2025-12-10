resource "google_folder" "main" {
  display_name = "${var.company}-${var.dept}-${var.project}"
  parent       = "folders/${var.standard_folder_id}"
}