// Variables to use accross the project
// which can be accessed by var.project_id
variable "project_id" {
  description = "The project ID to host the cluster in"
  default     = "mlops-463107"
}

variable "region" {
  description = "The region the cluster in"
  default     = "asia-southeast1"
}

variable "self_link" {
  description = "The self_link of the network to attach this firewall to"
  default = "global/networks/default"
}

variable "key" {
  description = "The key to use for the project"
  default = "mlops-463107-8f939268fde5.json"
}