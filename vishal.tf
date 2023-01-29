//Describing Provider
provider "aws" {
  region  = "ap-south-1"
  profile = "vishal"
}

//Creating Key
resource "tls_private_key" "tls_key" {
  algorithm = "RSA"
}

//Generating Key-Value Pair
resource "aws_key_pair" "generated_key" {
  key_name   = "vishal1-env-key"
  public_key = "${tls_private_key.tls_key.public_key_openssh}"
  
  depends_on = [
    tls_private_key.tls_key
  ]
}


//Saving Private Key PEM File
resource "local_file" "key-file" {
  content  = "${tls_private_key.tls_key.private_key_pem}"
  filename = "vishal1-env-key.pem"
  
  depends_on = [
    tls_private_key.tls_key
  ]
}

//Creating Variable for AMI_ID
variable "ami_id" {
  type    = string
  default = "ami-0447a12f28fddb066"
}

//Creating Variable for AMI_Type
variable "ami_type" {
  type    = string
  default = "t2.micro"
}

//Creating Security Group
resource "aws_security_group" "web-SG" {
  name        = "Terraform-SG"
  description = "Web Environment Security Group"


  //Adding Rules to Security Group 
  ingress {
    description = "SSH Rule"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "HTTP Rule"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

//Creating a S3 Bucket for Terraform Integration
resource "aws_s3_bucket" "vishal-bucket" {
  bucket = "vishal-static-data-bucket"
  acl    = "public-read"
}

//Putting Objects in S3 Bucket
resource "aws_s3_bucket_object" "web-object1" {
  bucket = "${aws_s3_bucket.vishal-bucket.bucket}"
  key    = "vishal.png"
  source = "/home/vishal/Desktop/terr/vishal.png"
  acl    = "public-read"
}

//Launching EC2 Instance
resource "aws_instance" "web" {
  ami             = "${var.ami_id}"
  instance_type   = "${var.ami_type}"
  key_name        = "${aws_key_pair.generated_key.key_name}"
  security_groups = ["${aws_security_group.web-SG.name}","default"]

  //Labelling the Instance
  tags = {
    Name = "Web-Env"
    env  = "Production"
  } 

  depends_on = [
    aws_security_group.web-SG,
    aws_key_pair.generated_key
  ]
}

resource "null_resource" "remote1" {
  
  depends_on = [ aws_instance.web, ]
  //Executing Commands to initiate WebServer in Instance Over SSH 
  provisioner "remote-exec" {
    connection {
      agent       = "false"
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${tls_private_key.tls_key.private_key_pem}"
      host        = "${aws_instance.web.public_ip}"
    }
    
    inline = [
      "sudo yum install httpd git -y",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd",
    ]

}

}
//Creating EBS Volume
resource "aws_ebs_volume" "web-vol" {
  availability_zone = "${aws_instance.web.availability_zone}"
  size              = 1
  
  tags = {
    Name = "ebs-vol"
  }
}


//Attaching EBS Volume to a Instance
resource "aws_volume_attachment" "ebs_att" {
  device_name  = "/dev/sdh"
  volume_id    = "${aws_ebs_volume.web-vol.id}"
  instance_id  = "${aws_instance.web.id}"
  force_detach = true 


  provisioner "remote-exec" {
    connection {
      agent       = "false"
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${tls_private_key.tls_key.private_key_pem}"
      host        = "${aws_instance.web.public_ip}"
    }
    
    inline = [
      "sudo mkfs.ext4 /dev/xvdh",
      "sudo mount /dev/xvdh /var/www/html/",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone https://github.com/rohitg00/Terraform-Build-AWS.git /var/www/html/",
    ]
  }


  depends_on = [
    aws_instance.web,
    aws_ebs_volume.web-vol
  ]
}
