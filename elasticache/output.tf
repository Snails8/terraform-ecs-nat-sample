# redisのhostnameはcache_nodesのオブジェクト内に眠っている
# 作成後のoutput及びssmの環境変数で使用

# https://github.com/turnerlabs/terraform-aws-elasticache-redis/blob/master/outputs.tf
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_cluster#cache_nodes
# https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-elasticache-cache-cluster.html
output "redis_hostname" {
  value = aws_elasticache_cluster.main.cache_nodes
}