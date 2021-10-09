# sample-terraform
## setup

```
touch ec2/.sample-ec2-key.pub

// 公開鍵情報を記述
vim ec2/.sample-ec2-key.pub
```

```
$ docker-compose build
$ docker-compose up -d
$ docker-compose exec terraform /bin/ash
```

```
# terraform init
# terraform plan
# terraform apply

# terraform destroy
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
###  親からAZとapp_nameを受け取る
variable "app_name" {
type = string
}

variable "azs" {
type = list(string)
}

### locals 値の使用 
https://www.terraform.io/docs/language/values/locals.html

local values とは
・Local Valuesとはモジュール内に閉じて使える変数 (module内のローカル変数のようなもの)
・tfファイル内の変数は基本的にLocal Valuesを使う
・特に判定処理はLocal Valuesで明確な名前をつけること

variableとの違い
・Local Valuesには関数や他リソースの参照などが書ける (DRY 意識するときとか)
・Local Valuesは外部からの値の設定ができない
・Variableを使うのは外部からのインプットにする場合

* 余談 variable 様々な値の設定方法
・apply実行時に対話的に入力
・コマンドラインから-varオプションや-ver-fileオプションで指定
・terraform.tfvarsファイルで指定
・環境変数(TF_VAR_xxxなど)で指定
・variableの定義時にデフォルト値を明示
つまりvariableは外部から意図しない値が入力される可能性がある。

```terraform
locals {
  load_balancer_count = "${var.use_load_balancer == "" ? 1 : 0}"
  switch_count        = "${local.load_balancer_count}"
}

resource sakuracloud_load_balancer "lb" {
  count = "${local.load_balancer_count}"
}

resource sakuracloud_switch "sw" {
  count = "${local.switch_count}"
}
```
### 注意点
・commaは書くな
Error: Unexpected comma after argument

・main.tfを編集したらinitしろ