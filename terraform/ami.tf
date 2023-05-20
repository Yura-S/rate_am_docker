#Getting AMI created by packer
data "aws_ami" "SiteImage" {
  most_recent = true

  owners = ["self"]
  tags = {
    Name   = "WebSiteImage"
  }
}
