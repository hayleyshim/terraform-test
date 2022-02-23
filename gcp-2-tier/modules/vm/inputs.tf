variable "instance_name" {
    type = string
}

variable "machine_type" {
    type = string
}

variable "vm_zone" {
    type = string 
}

variable "machine_image" {
    type = string
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

variable "name" {
  type = string
}

variable "vm-type" {
  type    = string
  default = "f1-micro"
}

variable "vm-startup-script" {
  type    = string
  default = "apt update && apt -y install apache2 && echo '<html><body><p>Linux startup script added directly.</p></body></html>' > /var/www/html/index.html"
}

variable "frontend-port" {
  type = number
}

variable "backend-port" {
  type = number
}

variable "vm-image" {
  type    = string
  default = "debian-cloud/debian-9"
}
