# terracube

“There are only two hard problems in computer science: cache invalidation, off-by-1 errors, and naming things” 
– random software professional

Enter Terracube, a simple and elegant sample application demonstrating continuous deployment of infrastructure using circleci, terraform, and jfrog for state-file management.

## Getting Started

You’ll need:

1.	Terraform
2.	CircleCI
3.	Github
4.	AWS account (with corresponding S3 bucket)
5. (Optional) JFrog Artifactory for statefile management

Clone the repo and copy the vars template file into a file called `terraform.tfvars`. There are several options when it comes to specifying which AWS credentials / IAM profile to use. Assuming you have the AWS CLI installed and configured locally, terraform will use the default IAM profile. This can be customized by leveraging the `profile` & `shared_credentials_file` variables.

A Context populated with valid AWS credentials is used for authentication from CircleCI to AWS; Contexts will be mounted to *all* jobs that interface with AWS, including `plan` jobs.
