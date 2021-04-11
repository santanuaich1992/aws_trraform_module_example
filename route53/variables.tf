variable "vpc_id" {}

variable "hostname" {
  type = list(string)
}

variable "arecord" {
  type = list(string)
}
