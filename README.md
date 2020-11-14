# Auto Scaling Group with Rolling Deploy 

This folder contains an example [Terraform](https://www.terraform.io/) configuration that defines a module for 
deploying a cluster of web servers (using [EC2](https://aws.amazon.com/ec2/) and [Auto 
Scaling](https://aws.amazon.com/autoscaling/)) in an [Amazon Web Services (AWS) account](http://aws.amazon.com/). 
The Auto Scaling Group is able to do a zero-downtime deployment when you update any of it's properties.

## Quick start

Terraform modules are not meant to be deployed directly. Instead, you should be including them in other Terraform 
configurations. See [smithlabs/hello-world-terraform-go-demo](https://github.com/smithlabs/hello-world-terraform-go-demo)
for examples.
