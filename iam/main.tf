# ==========================================================
# IAM 設定
# ECS-Agentが使用するIAMロール や タスク(=コンテナ)に付与するIAMロール の定義
# ==========================================================
# 第三者に「自アカウントのAPI権限を委譲する」ためのもの

# AWS->ECSのサービスを信頼する => ECSがAssumeRoleを行えるようになる
resource "aws_iam_role" "task_execution" {
  name = "${var.app_name}-TaskExecution"
  assume_role_policy = file("./iam/task_execution_role.json")
}

# policy の追加 (Log 関連)
resource "aws_iam_role_policy" "task_execution" {
  role = aws_iam_role.task_execution.id
  policy = file("./iam/task_execution_role_policy.json")
}

# role にpolicy をattach するときに必要な設定
resource "aws_iam_role_policy_attachment" "task_execution" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}