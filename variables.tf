variable "aws_region" {
  description = "Region where instances get created"
  default     = "us-east-1"
}

variable "aws_instance_profile" {
  description = "AWS IAM profile used for provisioning"
  # default     = "default"
}

variable "s3_bucket_name" {
  description = "Name of s3 bucket to persist state"
}

variable "s3_bucket_key" {
  description = "Name of key/file used in s3 bucket"
}

variable "s3_bucket_region" {
  description = "Region where s3 bucket is stored"
}
