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
  key_name   = "vishal-env-key"
  public_key = "${tls_private_key.tls_key.public_key_openssh}"
  
  depends_on = [
    tls_private_key.tls_key
  ]
}


//Saving Private Key PEM File
resource "local_file" "key-file" {
  content  = "${tls_private_key.tls_key.private_key_pem}"
  filename = "vishal-env-key.pem"
  
  depends_on = [
    tls_private_key.tls_key
  ]
}