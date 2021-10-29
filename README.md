# sample-terraform
![Image](.docs/ECS.drawio.png)
## setup
1. Create terraform environment with docker
```
// set your credential keys in .env
$ cp .env.example .env

// set your public key
$ vim ec2/sample-ec2-key.pub
```

2. Run terraform
```
$ docker-compose up -d
$ docker-compose exec terraform /bin/ash

設定を変えた場合、毎回は走らせること
# terraform init 

// 	initialization (if you change a file , please run)
# terraform plan

// create aws resources 
# terraform apply

// destroy 
# terraform destroy
```

3. ECR
```
$ aws ecr create-repository --repository-name sample-app
$ aws ecr create-repository --repository-name sample-nginx
```
4. 
Q  how to connect ec2 ?
```
$ ssh -i ~/.ssh/秘密鍵 ec2-user@IPアドレス
```

Q.  RDS instance failed to create 
please check .env value
```
https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_CreateDBInstance.html
・1〜16文字の英数字とアンダースコアを含めることができます。
・その最初の文字は文字でなければなりません。
・データベースエンジンによって予約された単語にすることはできません。

✕: ハイフン(-), ✕:誰もが使いそうなusername=admin (すでに予約されているため)
```

## CI/CD
It is a CI/CD env that does not directly handle credential information
Please be careful if you want to use
```
En
・When copying and pasting, pay attention to the repository specification destination (GHA-terraform.yml)
・Uncomment terraform and workflow in main.tf
・Set the following 3 environment variables on Github

Jp
・コピペする場合はリポジトリ指定先に注意(GHA-terraform.yml)
・main.tf 内の terraform とworkflowのコメントアウトを解除
・以下３つの環境変数をGithub上にセット
```

```
AWS_ROLE_ARN=引き受けるロールのARNを指定。OHA で作成される IAM ロールの ARN
AWS_WEB_IDENTITY_TOKEN_FILE=Web IDトークンファイルへのパス
AWS_DEFAULT_REGION=デフォルトのリージョン。東京リージョンを指定したい場合はap-northeast-1
```

## 運用 注意
ドメインをRoute53に登録していないと怒られるので注意

開発用と本番用で分けたい場合は
variable_des.tf のように分けて運用してください

## 懸念点
github-actionsでアプリケーションのdeployをしているため、task-definition が二重管理になってしまっている。

外部デプロイを利用すれば回避できるが以下の問題がある
- https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/userguide/deployment-type-external.html

対応策

・AWS Copilot を使用
https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/userguide/getting-started-aws-copilot-cli.html

・パイプラインの使用
https://zenn.dev/reireias/articles/8e987af2762eaa

理想
github-actions にCodePipelineをかませる


## ディレクトリ構造

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