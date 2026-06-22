locals {
  engine              = "postgres"
  region              = "us-east1"
  asset_name          = "bap-dev"
  environment         = "dev"
  product             = "apps"
  project_id          = "${local.asset_name}-${local.environment}-${local.product}"
  platform_project_id = "${local.asset_name}-non-prod-platform"
  labels = {
    env                  = local.environment,
    shared               = "false",
    app                  = local.product
  }

  inputs = {
    baptist-apps = {
      db_name           = "${local.asset_name}-${local.environment}-baptist-apps-db"
      db_version        = "POSTGRES_15"
      db_edition        = "ENTERPRISE"
      db_zone           = "us-east1-a"
      db_tier           = "db-custom"
      db_disk_size      = "5"
      db_disk_type      = "PD_SSD"
      user_name         = "user"
      #db_dns            = "apps-db.${data.google_dns_managed_zone.dns_zone.dns_name}"
      #managed_zone      = "${local.product}-private-zone"
      db_pw_secret_name = "${local.environment}-password"


      additional_users = []
      additional_databases = [
        {
          name      = "db1"
          charset   = "UTF8"
          collation = "en_US.UTF8"
        },
        {
          name      = "db2"
          charset   = "UTF8"
          collation = "en_US.UTF8"
        },
      ]
      db_data_cache_enabled = true
      database_flags = [
        { name = "cloudsql.logical_decoding", value = "on" }
      ]
      backup_configuration = {
        binary_log_enabled             = false
        enabled                        = true
        start_time                     = "23:55"
        location                       = "us-east1"
        transaction_log_retention_days = 7
        retained_backups               = 7
        retention_unit                 = "COUNT"
      }
      ip_configuration = {
        ipv4_enabled    = false
        require_ssl     = false
        #ssl_mode        = "ENCRYPTED_ONLY"
        #private_network = data.google_compute_subnetwork.dev_shared_subnet.network
      }
      read_replicas = [
        {
          name              = "-0"
          zone              = "us-east1-c"
          availability_type = "REGIONAL"
          tier              = "db-custom"
          ip_configuration = {
            ipv4_enabled    = false
            require_ssl     = false
            ssl_mode        = "ENCRYPTED_ONLY"
            private_network = data.google_compute_subnetwork.dev_shared_subnet.network

            authorized_networks = []
          }
          database_flags = [{ name = "cloudsql.logical_decoding", value = "on" }]
          disk_type      = "PD_SSD"
          user_labels    = { terraform = "yes" }
          insights_config = {
            query_plans_per_minute  = 5
            query_string_length     = 1024
            record_application_tags = true
            record_client_address   = true
          }
          ssl_mode = "ENCRYPTED_ONLY"
        }
      ]
      read_replica_deletion_protection_enabled = true
    }
  }
}
