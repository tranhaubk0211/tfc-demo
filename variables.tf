# variables.tf

variable "project_id" {
  type        = string
  default     ="rich-agency-354602"
  description = "The GCP Project ID where resources will be deployed."
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "Target region for storage and networking resources."
}

variable "zone" {
  type        = string
  default     = "us-central1-a"
  description = "Target zone for the AI Workbench instance."
}
