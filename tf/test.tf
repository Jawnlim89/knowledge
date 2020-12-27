provider "alicloud" {
alias = "test"
}
# this is to create vpc 

resource "alicloud_vpc" "vpc1" { 

  name       = "jawn-vpc-demo1" 

  cidr_block = "172.16.0.0/12" 

} 

# this is to create vSwitch 

resource "alicloud_vswitch" "vsw1" { 

  vpc_id            = "alicloud_vpc.vpc1.id" 

  cidr_block        = "172.16.0.0/21" 

  availability_zone = "ap-southeast-1a" 

  depends_on = [alicloud_vpc.vpc1] 

} 
