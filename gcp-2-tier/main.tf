###########################################
#                                         #
#                PROVIDER                 # 
#                                         #
###########################################

# provide 
provider "google" {
  # credentials = file("token.json")
  project     = var.project_name
  region      = var.region
  zone        = var.zone
}


###########################################
#                                         #
#                BACKEND                  # 
#                                         #
###########################################

# Configure the backend (since variables are not allowed for backend configuration, setting the credentials 
# through the gitlab cicd variables)
//terraform {
//  backend "gcs" {
//    bucket = "tf_backend_gcp_banuka_jana_jayarathna_k8s"
//    prefix = "terraform/gcp/boilerplate"
//  }
//}


###########################################
#                                         #
#                RESOURCES                # 
#                                         #
###########################################

# creating the network 
module "network" {
  source = "./modules/network"

  network_name = "network"
  auto_create_subnetworks = "false"
}

# creating the public subnet 
module "public_subnet" {
  source = "./modules/subnetworks"

  subnetwork_name = "public-subnetwork"
  cidr = "10.10.10.0/24"
  subnetwork_region = "us-west2"
  network = module.network.network_name
  depends_on_resoures = [module.network]
  private_ip_google_access = "false"
}

# creating the private subnet 
module "private_subnet" {
  source = "./modules/subnetworks"

  subnetwork_name = "private-subnetwork"
  cidr = "10.10.20.0/24"
  subnetwork_region = "us-west2"
  network = module.network.network_name
  depends_on_resoures = [module.network]
  private_ip_google_access = "false"
}

# creating the private subnet - 추가(db) 
module "private_subnet2" {
  source = "./modules/subnetworks"

  subnetwork_name = "private-subnetwork2"
  cidr = "10.10.30.0/24"
  subnetwork_region = "us-west2"
  network = module.network.network_name
  depends_on_resoures = [module.network]
  private_ip_google_access = "false"
}

# create the vm in public subnet
module "public_instance" {
  source = "./modules/vm"

  instance_name = "public-vm"
  machine_type = "f1-micro"
  vm_zone = "us-west2-a"
  network_tags = ["public-vm", "test"]
  machine_image = "ubuntu-1804-bionic-v20200317"
  subnetwork = module.public_subnet.sub_network_name
  metadata_Name_value = "public_vm"
  
}

# create the vm in public subnet
module "private_instance" {
  source = "./modules/vm"

  instance_name = "private-vm1"
  machine_type = "f1-micro"
  vm_zone = "us-west2-a"
  network_tags = ["private-vm", "test"]
  machine_image = "ubuntu-1804-bionic-v20200317"
  subnetwork = module.private_subnet.sub_network_name
  metadata_Name_value = "private_vm"
}


# create the vm in public subnet - 추가(vm)
module "private_instance2" {
  source = "./modules/vm"

  instance_name = "private-vm2"
  machine_type = "f1-micro"
  vm_zone = "us-west2-a"
  network_tags = ["private-vm", "test"]
  machine_image = "ubuntu-1804-bionic-v20200317"
  subnetwork = module.private_subnet.sub_network_name
  metadata_Name_value = "private_vm"
}

# create the vm in public subnet - 추가(vm)
module "private_instance3" {
  source = "./modules/vm"

  instance_name = "private-vm3"
  machine_type = "f1-micro"
  vm_zone = "us-west2-a"
  network_tags = ["private-vm", "test"]
  machine_image = "ubuntu-1804-bionic-v20200317"
  subnetwork = module.private_subnet.sub_network_name
  metadata_Name_value = "private_vm"
}

# create the vm in public subnet - 추가(vm-db)
module "private_vm_db" {
  source = "./modules/vm"

  instance_name = "private_vm_db"
  machine_type = "f1-micro"
  vm_zone = "us-west2-a"
  network_tags = ["private-vm", "test"]
  machine_image = "ubuntu-1804-bionic-v20200317"
  subnetwork = module.private_subnet2.sub_network_name
  metadata_Name_value = "private_vm"
}

# create firewall rule with ssh access to the public instance/s
module "firewall_rule_public_ssh_all" {
  source = "./modules/firewall_rules"

  firewall_rule_name = "ssh-all-public-instances"
  network = module.network.network_name
  protocol_type = "tcp"
  ports_types = ["22"]
  source_tags = null
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["public-vm"]
}

# create firewall rule to access only the public vm with icmp
module "firewall_rule_icmp_public" {
  source = "./modules/firewall_rules"

  firewall_rule_name = "access-public-vm"
  network = module.network.network_name
  protocol_type = "icmp"
  ports_types = null
  source_tags = null
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["public-vm"]
}

# firwall rule for private instances 
module "firewall_rule_private_vm" {
  source = "./modules/firewall_rules"

  firewall_rule_name = "private-vm"
  network = module.network.network_name
  protocol_type = "icmp"
  ports_types = null
  source_tags = ["public-vm"]
  source_ranges = null
  target_tags = ["private-vm","private-vm2","private-vm3","private_vm_db"]
}



