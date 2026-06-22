module "cloud_sql_mysql" {
  count   = var.engine == "mysql" ? 1 : 0
  source  = "terraform-google-modules/sql-db/google//modules/mysql"
  version = "27.1.0"

  project_id        = var.project_id
  region            = var.region
  name              = var.db_name
  database_version  = var.db_version
  edition           = var.db_edition
  tier              = var.db_tier
  zone              = var.db_zone
  availability_type = var.db_availability_type
  disk_size         = var.db_disk_size
  disk_type         = var.db_disk_type

  root_password     = null
  enable_default_db = true
  user_name         = var.db_user_name

  additional_users     = var.db_additional_users
  additional_databases = var.db_additional_databases

  backup_configuration = var.backup_configuration

  read_replicas                            = var.read_replicas
  read_replica_deletion_protection_enabled = var.read_replica_deletion_protection_enabled

  ip_configuration = var.ip_configuration

  database_flags = var.database_flags

  data_cache_enabled          = var.db_data_cache_enabled
  deletion_protection         = var.deletion_protection
  deletion_protection_enabled = var.deletion_protection
  maintenance_window_day      = 2
  maintenance_window_hour     = 3
  enable_dataplex_integration = true
  retain_backups_on_delete    = true
  insights_config             = var.insights_config
  user_labels                 = var.user_labels
}

module "cloud_sql_postgres" {
  count   = var.engine == "postgres" ? 1 : 0
  source  = "terraform-google-modules/sql-db/google//modules/postgresql"
  version = "27.1.0"

  project_id        = var.project_id
  region            = var.region
  name              = var.db_name
  database_version  = var.db_version
  availability_type = var.db_availability_type
  edition           = var.db_edition
  tier              = var.db_tier
  zone              = var.db_zone
  disk_size         = var.db_disk_size
  disk_type         = var.db_disk_type

  root_password     = null
  enable_default_db = true
  user_name         = var.db_user_name


  additional_users     = var.db_additional_users
  additional_databases = var.db_additional_databases

  backup_configuration = var.backup_configuration

  read_replicas                            = var.read_replicas != null ? var.read_replicas : null
  read_replica_deletion_protection_enabled = var.read_replica_deletion_protection_enabled != null ? var.read_replica_deletion_protection_enabled : null

  ip_configuration = var.ip_configuration

  database_flags = var.database_flags

  data_cache_enabled          = var.db_data_cache_enabled
  deletion_protection         = var.deletion_protection
  deletion_protection_enabled = var.deletion_protection
  maintenance_window_day      = 2
  maintenance_window_hour     = 3
  enable_dataplex_integration = true
  retain_backups_on_delete    = true
  insights_config             = var.insights_config
  user_labels                 = var.user_labels
  activation_policy           = var.activation_policy
}

resource "google_dns_record_set" "db-internal-mysql" {
  count        = var.engine == "mysql" && var.db_dns_enable == true && var.db_dns != "" && var.managed_zone != "" ? 1 : 0
  name         = var.db_dns
  type         = "A"
  ttl          = 300
  project      = var.project_id
  managed_zone = var.managed_zone
  rrdatas      = [module.cloud_sql_mysql[0].private_ip_address]
}
resource "google_dns_record_set" "db-internal-mysql_read" {
  count = (
    var.engine == "mysql"
    && var.db_dns_enable == true
    && var.db_dns != ""
    && var.managed_zone != ""
    && length(module.cloud_sql_mysql[0].replicas_instance_first_ip_addresses) > 0
  ) ? 1 : 0
  name         = "read-${var.db_dns}"
  type         = "A"
  ttl          = 300
  project      = var.project_id
  managed_zone = var.managed_zone
  rrdatas      = [module.cloud_sql_mysql[0].replicas_instance_first_ip_addresses[0][0].ip_address]
}
resource "google_dns_record_set" "db-internal-postgres" {
  count        = var.engine == "postgres" && var.db_dns_enable == true && var.db_dns != "" && var.managed_zone != "" ? 1 : 0
  name         = var.db_dns
  type         = "A"
  ttl          = 300
  project      = var.project_id
  managed_zone = var.managed_zone
  rrdatas      = [module.cloud_sql_postgres[0].private_ip_address]
}
resource "google_dns_record_set" "db-internal-postgres_read" {
  count = (
    var.engine == "postgres"
    && var.db_dns_enable == true
    && var.db_dns != ""
    && var.managed_zone != ""
    && length(module.cloud_sql_postgres[0].replicas_instance_first_ip_addresses) > 0
  ) ? 1 : 0
  name         = "read-${var.db_dns}"
  type         = "A"
  ttl          = 300
  project      = var.project_id
  managed_zone = var.managed_zone
  rrdatas      = [module.cloud_sql_postgres[0].replicas_instance_first_ip_addresses[0][0].ip_address]
}

resource "google_secret_manager_secret" "db_password" {
  secret_id = upper(var.secret_name)
  project   = var.platform_project_id == null ? var.project_id : var.platform_project_id

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret" "additional_user_db_password" {
  for_each  = { for user in module.cloud_sql_mysql[0].additional_users : user.name => user }
  secret_id = upper(join("-", [var.environment, each.value.name, "DB-PW"]))
  project   = var.platform_project_id == null ? var.project_id : var.platform_project_id

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "secret-version-basic-mysql" {
  count       = var.engine == "mysql" ? 1 : 0
  secret      = google_secret_manager_secret.db_password.id
  secret_data = module.cloud_sql_mysql[0].generated_user_password
}

resource "google_secret_manager_secret_version" "secret-version-basic-postgres" {
  count       = var.engine == "postgres" ? 1 : 0
  secret      = google_secret_manager_secret.db_password.id
  secret_data = module.cloud_sql_postgres[0].generated_user_password
}
resource "google_secret_manager_secret_version" "secret_version_basic_mysql" {
  for_each    = { for user in module.cloud_sql_mysql[0].additional_users : user.name => user }
  secret      = google_secret_manager_secret.db_password.id
  secret_data = each.value.password
}