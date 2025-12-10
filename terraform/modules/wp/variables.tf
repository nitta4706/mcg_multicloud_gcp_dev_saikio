variable "region" {
  type = string
}
variable "prj_mcg_ope_admin" {
  type = string
}
variable "billing_account_id" {
  type = string
}
variable "company" {
  type = string
}
variable "dept" {
  type = string
}
variable "project" {
  type = string
}
locals {
  prefix = "${var.company}-${var.dept}-${var.project}"
}
variable "env" {
  type = string
}
variable "folder_id" {
  type = string
}
variable "image_url" {
  type = string
  default="us-docker.pkg.dev/cloudrun/container/hello"
}
variable "main_project_id" {
  type = string
}
variable "domain_name" {
  type = string
}