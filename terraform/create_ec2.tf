resource "aws_instance" "tf_instance" {
  ami           = "${data.aws_ami.SiteImage.id}"
  instance_type = "t2.micro"

  subnet_id                   = aws_subnet.tf_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.tf_sg.id]
  associate_public_ip_address = true

  tags = {
    "Name" : "Website"
  }
}
