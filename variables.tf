variable "vpc_cidr"{
    default = "10.0.0.0/16"
}
variable "project"{
    type = string
 }
 variable "environment"{
    type = string
 }
 variable "vpc_tags"{
   default = {}
 }
 variable "gw_tags"{
   default ={}
 }

 variable "public_subnet_tags"{
   default = {}
 }
 variable "private_subnet_tags"{
   default = {}
 }
 variable "database_subnet_tags"{
   default = {}
 }
variable "public_subnet_cidr"{
   type = list
    default = ["10.0.1.0/24","10.0.2.0/24"]
}
variable "private_subnet_cidr"{
   type = list
    default = ["10.0.11.0/24","10.0.12.0/24"]
}
variable "database_subnet_cidr"{
   type = list
    default = ["10.0.21.0/24","10.0.22.0/24"]
}
variable "peering_require"{
   default = false
}