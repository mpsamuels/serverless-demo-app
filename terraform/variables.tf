variable "domain_name" {
  type        = string
  description = "The hosted zone domain name used by the HTML frontend"
}

variable "prefix_name" {
  type        = string
  description = "String to prefix to resources names"
}

variable "ssm_secret" {
  type        = string
  description = "String to prefix to resources names"
}