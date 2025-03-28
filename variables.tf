variable "aws_region" {
  default = "ap-south-1"
}

variable "jenkins_ami_id" {
  default = "ami-0e35ddab05955cf57"
}

variable "jenkins_instance_type" {
  default = "t2.medium"
}

variable "jenkins_disk_space" {
  default = "25"
}

variable "jenkins_key_name" {
  default = "Opstree"
}

variable "SonarNexusServer_instance_ami_id" {
  default = "ami-0e35ddab05955cf57"
}

variable "SonarNexusServer_instance_type" {
  default = "t2.large"
}

variable "SonarNexusServer_disk_space" {
  default = "15"
}

variable "SonarNexusServer_instance_key_name" {
  default = "Opstree"
}

variable "MongoDbServer_instance_ami_id" {
  default = "ami-0e35ddab05955cf57"
}

variable "MongoDbServer_instance_type" {
  default = "t2.micro"
}

variable "MongoDbServer_disk_space" {
  default = "10"
}

variable "MongoDbServer_instance_key_name" {
  default = "Opstree"
}
