variable "name" {
  type        = string
  description = "Name of the ec2 instance"
}
variable "ami" {
  type        = string
  description = "AMI to use for the instance"
  default     = "ami-0c75b861029de4030" // Debian 11
}
variable "instance_type" {
  type        = string
  description = "Instance type to use for the instance"
  default     = "t3.nano"
}
variable "user_data" {
  description = "User data to pass to the instance"
  default     = null
}
variable "key_name" {
  type        = string
  description = "SSH Key name to use for the instance"
}
variable "zone_id" {
  type        = string
  description = "Cloudflare Zone ID to use for the DNS record"
}
