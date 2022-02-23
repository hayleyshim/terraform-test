variable "instance_name" {
    type = string
}

variable "machine_type" {
    type = string
    default = "f1-micro" # webserver 추가 
}

variable "vm_zone" {
    type = string 
}

variable "machine_image" {
    type = string
    default = "debian-cloud/debian-9" #webserver 추가
}

# webserver 추가 
variable "vm-startup-script" {
  type    = string
  default = "apt update && apt -y install apache2 && echo '<html><body><p>Linux startup script added directly.</p></body></html>' > /var/www/html/index.html"
}

variable "subnetwork" {
    type = string
}

variable "network_tags" {
    type = list
}

variable "metadata_Name_value" {
    type = string
}


###########################################
#                                         #
#                webserver 추가            # 
#                                         #
###########################################


#variable "backend-port" {
#  type = number
#}

#variable "frontend-port" {
#  type = number
#}

variable "source-ranges" {
  type    = list(string)
  default = ["35.191.0.0/16", "130.211.0.0/22"]
}

variable "ip_protocol" {
  type    = string
  default = "tcp"
}