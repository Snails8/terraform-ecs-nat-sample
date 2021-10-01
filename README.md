# sample-terraform

## 構文
### sample

<h3>Module化</h3>
・別ディレクトリに格納することができる
・引数をもたせて渡している
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