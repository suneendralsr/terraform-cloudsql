variable "engine" {
  description = "Type of database engine. Allowed values: 'mysql' or 'postgres'"
  type        = string
  validation {
    condition     = contains(["mysql", "postgres"], var.engine)
    error_message = "Engine must be either 'mysql' or 'postgres'."
  }
}

variable "project_id" {
  type        = string
  description = "GCP project ID"
  nullable    = false
}

variable "platform_project_id" {
  type        = string
  description = "GCP project ID for platform"
  default     = null
}

variable "region" {
  description = "The ID of the region in which to provision resources."
  type        = string
  default     = "me-central2"
}

variable "db_name" {
  description = "The name of the default database to create. This should be unique per Cloud SQL instance."
  type        = string
}

variable "db_version" {
  description = "The database version to use."
  type        = string
}

variable "db_tier" {
  description = "The tier for the master instance."
  type        = string
}

variable "db_zone" {
  description = "The zone for the master instance, it should be something like: us-central1-a, us-east1-c. By default the zone is me-central2-a"
  type        = string
  default     = "me-central2-a"
}

variable "db_user_name" {
  description = "The name of the default user"
  type        = string
}

variable "db_disk_size" {
  description = "The disk size (in GB) for the master instance"
  type        = number
}

variable "db_disk_type" {
  description = "The disk type for the master instance."
  type        = string
}

variable "db_edition" {
  description = "The edition of the instance, can be ENTERPRISE or ENTERPRISE_PLUS."
  type        = string
  default     = "ENTERPRISE"
}

variable "db_additional_users" {
  description = "List of maps of additional users and passwords"
  type = list(object({
    name            = string
    password        = optional(string)
    random_password = bool
    host            = optional(string)
    type            = string
  }))
  default = []
}

variable "db_additional_databases" {
  description = "A list of databases to be created in your cluster"
  type = list(object({
    name      = string
    charset   = string
    collation = string
  }))
  default = []
}

variable "backup_configuration" {
  description = "The backup_configuration settings subblock for the database setings"
  type = object({
    binary_log_enabled             = optional(bool, false)
    enabled                        = optional(bool, false)
    start_time                     = optional(string)
    location                       = optional(string)
    transaction_log_retention_days = optional(string)
    retained_backups               = optional(number)
    retention_unit                 = optional(string)
    point_in_time_recovery_enabled = optional(bool, false)
  })
}

# variable "private_network" {
#   description = "Name of the private Network"
#   type        = string
# }

variable "db_data_cache_enabled" {
  description = "Whether data cache is enabled for the instance. Defaults to false. Feature is only available for ENTERPRISE_PLUS tier and supported database_versions"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Used to block Terraform from deleting a SQL Instance."
  type        = bool
  default     = true
}

variable "db_availability_type" {
  type        = string
  default     = "ZONAL"
  description = "The availability type for the Cloud SQL instance.This is only used to set up high availability for the PostgreSQL instance. Can be either ZONAL or REGIONAL"
}

variable "secret_name" {
  description = "Secret Name for the database password"
  type        = string
}

variable "db_dns" {
  description = "Internal DNS for database"
  type        = string
}

variable "managed_zone" {
  description = "Cloud DNS Zone to allocate dns record"
  type        = string
}

variable "database_flags" {
  description = "The database flags for the Cloud SQL instance."
  type = list(object({
    name  = string
    value = string
  }))
}

variable "db_dns_enable" {
  description = "Flag to enable or disable the creation of a DNS record pointing to the Cloud SQL instance. Set to true to create the record, false to skip DNS configuration."
  type        = bool
  default     = true
}

variable "user_labels" {
  description = "A set of key/value label pairs to assign to the instance."
  type        = map(string)
  default     = {}
}
variable "read_replicas" {
  description = "List of read replicas to create. Encryption key is required for replica in different region. For replica in same region as master set encryption_key_name = null"
  default     = []
  type = list(object({
    name                  = string
    name_override         = optional(string)
    tier                  = optional(string)
    edition               = optional(string)
    availability_type     = optional(string)
    zone                  = optional(string)
    disk_type             = optional(string)
    disk_autoresize       = optional(bool)
    disk_autoresize_limit = optional(number)
    disk_size             = optional(string)
    user_labels           = map(string)
    database_flags = optional(list(object({
      name  = string
      value = string
    })), [])
    insights_config = optional(object({
      query_plans_per_minute  = optional(number, 5)
      query_string_length     = optional(number, 1024)
      record_application_tags = optional(bool, false)
      record_client_address   = optional(bool, false)
    }), null)
    ip_configuration = object({
      authorized_networks                           = optional(list(map(string)), [])
      ipv4_enabled                                  = optional(bool)
      private_network                               = optional(string)
      ssl_mode                                      = optional(string, "ENCRYPTED_ONLY")
      allocated_ip_range                            = optional(string)
      enable_private_path_for_google_cloud_services = optional(bool, false)
      psc_enabled                                   = optional(bool, false)
      psc_allowed_consumer_projects                 = optional(list(string), [])
    })
    encryption_key_name = optional(string)
    data_cache_enabled  = optional(bool)
  }))
}

variable "read_replica_deletion_protection_enabled" {
  description = "Enables protection of replica instance from accidental deletion across all surfaces (API, gcloud, Cloud Console and Terraform)."
  type        = bool
  default     = false
}

variable "insights_config" {
  type = object({
    query_plans_per_minute  = optional(number, 5)
    query_string_length     = optional(number, 1024)
    record_application_tags = optional(bool, false)
    record_client_address   = optional(bool, false)
  })
  description = "The insights_config settings for the database."
  default     = null
}

variable "ip_configuration" {
  type = object({
    authorized_networks                           = optional(list(map(string)), [])
    ipv4_enabled                                  = optional(bool, true)
    private_network                               = optional(string)
    ssl_mode                                      = optional(string, "ENCRYPTED_ONLY")
    allocated_ip_range                            = optional(string)
    enable_private_path_for_google_cloud_services = optional(bool, false)
    psc_enabled                                   = optional(bool, false)
    psc_allowed_consumer_projects                 = optional(list(string), [])
    server_ca_mode                                = optional(string)
    server_ca_pool                                = optional(string)
    custom_subject_alternative_names              = optional(list(string), [])
  })
  description = "The ip configuration for the Cloud SQL instances."
  default = {
    ipv4_enabled = false
    require_ssl  = false
  }
}

variable "activation_policy" {
  description = "The activation policy for the Cloud SQL instance.Can be either `ALWAYS`, `NEVER` or `ON_DEMAND`."
  default     = "ALWAYS"
  type        = string
}

variable "environment" {
  description = "The resource environment"
  type        = string
}
