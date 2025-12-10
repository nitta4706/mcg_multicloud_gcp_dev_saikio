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
variable "env" {
  type = string
}
variable "subnet_cidr" {
  type = string
}
variable "group_email" {
  type = string
}
variable "user_group_email" {
  type = string
}
variable "image_url" {
  type = string
  default = "us-docker.pkg.dev/cloudrun/container/hello"
}
variable "use_wp" {
  type = bool
  default = false
}
variable "domain_name" {
  type = string
  default = "example.com"
}