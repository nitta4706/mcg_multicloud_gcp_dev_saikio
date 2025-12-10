data "terraform_remote_state" "common" {
  backend = "gcs"
  config = {
    bucket = "mcg-ope-admin-dev-gha-tfstate"
    prefix = "__company__-__dept__-__project__/common"
  }
}

module "main" {
  source = "../../modules/main"

  region             = var.region
  prj_mcg_ope_admin  = var.prj_mcg_ope_admin
  billing_account_id = var.billing_account_id

  company          = var.company
  dept             = var.dept
  project          = var.project
  env              = var.env
  subnet_cidr      = var.subnet_cidr
  group_email      = var.group_email
  user_group_email = var.user_group_email

  folder_id = data.terraform_remote_state.common.outputs.folder_id
}

module "wp" {
  count = var.use_wp ? 1 : 0
  source = "../../modules/wp"

  region           = var.region
  prj_mcg_ope_admin  = var.prj_mcg_ope_admin
  billing_account_id = var.billing_account_id

  company          = var.company
  dept             = var.dept
  project          = var.project
  env              = var.env
  image_url        = var.image_url
  domain_name      = var.domain_name

  folder_id = data.terraform_remote_state.common.outputs.folder_id

  # mainモジュールの出力を取得
  main_project_id    = module.main.project_id

}