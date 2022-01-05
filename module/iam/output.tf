# ECS と関連付け
output "iam_role_task_execution_arn" {
  value = aws_iam_role.task_execution.arn
}