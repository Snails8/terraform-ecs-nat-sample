# DB_HOST (正確にはDB_HOST + 5432)
output "db_endpoint" {
  value = module.rds.endpoint
}

# SUBNETSに該当
output "db_subnets" {
  value = module.network.private_subnet_ids
}

# REDIS_HOST
output "redis_hostname" {
  value = module.elasticache.redis_hostname
}

# SECURITY_GROUPに該当
output "db_security_groups" {
  value = module.security_group.db_sg_id
}