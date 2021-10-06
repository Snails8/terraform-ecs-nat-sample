# sample-terraform

```
touch ec2/.sample-ec2-key.pub

// 公開鍵情報を記述
vim ec2/.sample-ec2-key.pub
```

ssh -i ~/.ssh/キーを指定 ec2-user@IPアドレス

## 構文
### Module
Module: リソースを集約して1つの機能としたもの

Moduleには２種類ある
・Child Module :特定の機能をまとめたもの他mModuleから呼ばれるように設計
・Root Module  :Terraformコマンドを実行するディレクトリにまとめられたTerraformリソースのこと。childに値を渡したり、呼び出したりする

Module は4つのブロックを Terraform ファイルに定義すること作成できる
・resource :Moduleが作成するインフラのリソース
・data     :既存のリソースを参照
・variable :変数
・output   :Moduleの値を外に渡す

root
```terraform
module "network" {
source = "./network"
app_name = var.app_name
azs = var.azs
}
```

子側では受け取れば良い
```terraform
#  親からAZとapp_nameを受け取る
variable "app_name" {
  type = string
}

variable "azs" {
  type = list(string)
}

// 略
```
#  親からAZとapp_nameを受け取る
variable "app_name" {
type = string
}

variable "azs" {
type = list(string)
}


### 注意点
・commaは書くな
Error: Unexpected comma after argument

・main.tfを編集したらinitしろ