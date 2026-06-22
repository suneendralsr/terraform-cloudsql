module "postgres" {
  source              = "./"
  engine              = local.engine
  project_id          = local.project_id
  platform_project_id = local.platform_project_id

  db_name          = local.inputs.digital-apps.db_name
  db_version       = local.inputs.digital-apps.db_version
  db_tier          = local.inputs.digital-apps.db_tier
  db_edition       = local.inputs.digital-apps.db_edition
  db_zone          = local.inputs.digital-apps.db_zone
  db_disk_size     = local.inputs.digital-apps.db_disk_size
  db_disk_type     = local.inputs.digital-apps.db_disk_type
  db_dns           = local.inputs.digital-apps.db_dns
  managed_zone     = local.inputs.digital-apps.managed_zone
  ip_configuration = local.inputs.digital-apps.ip_configuration

  db_user_name            = local.inputs.digital-apps.user_name
  secret_name             = local.inputs.digital-apps.db_pw_secret_name
  db_additional_users     = local.inputs.digital-apps.additional_users
  db_additional_databases = local.inputs.digital-apps.additional_databases
  backup_configuration    = local.inputs.digital-apps.backup_configuration
  db_data_cache_enabled   = local.inputs.digital-apps.db_data_cache_enabled

  database_flags                           = local.inputs.digital-apps.database_flags
  user_labels                              = local.labels
  read_replicas                            = local.inputs.digital-apps.read_replicas
  read_replica_deletion_protection_enabled = local.inputs.digital-apps.read_replica_deletion_protection_enabled
}
