variable "master" {
  default = {
    "base_name" = "master"
    "count"     = 1
    "disksize"  = 10737418240
    "memory"    = 2048
    "vcpu"      = 1
  }
}

variable "worker" {
  default = {
    "base_name" = "worker"
    "count"     = 3
    "disksize"  = 10737418240
    "memory"    = 1024
    "vcpu"      = 1
  }
}
