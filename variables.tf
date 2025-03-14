variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default     = "devops-practice-sm"
}

variable "region" {
  description = "The GCP region (not zone)"
  type        = string
  default     = "us-east5"
}

variable "zone" {
  description = "The GCP zone"
  type        = string
  default     = "us-east5-b"
}
