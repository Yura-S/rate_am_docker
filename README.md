Use website_deploy.sh script

Requirements:

packer
terraform
aws-cli
ansible

Creates ami of ubuntu with docker installed there. Then creating terraform infrastructure with ec2 instance using created ami. After creating instance ansible creates docker image there with installed nginx and rate.am website copy. In the end gives instance ip which configured to show website of docker file

uses my bucketforbackend s3 bucket for terraform backend
