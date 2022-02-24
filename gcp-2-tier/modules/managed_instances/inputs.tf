variable "project_id" {
  description = "The ID of the project where this VPC will be created"
}

variable "region" {
  description = "The the region where this will be deployed"
}

variable "zone" {
    description = "The zone within the region variable to deploy everything"
}

variable "prefix" {
    description = "The prefix for all of the objects being created"
}

variable "compute_image" {
    description = "The name of the image to use for creating compute instances within the instance group"
}
