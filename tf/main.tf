provider "alicloud" {} 

# this is to create vpc 

resource "alicloud_vpc" "vpc" { 

  name       = "jawn-vpc-demo" 

  cidr_block = "172.16.0.0/12" 

} 

# this is to create vSwitch 

resource "alicloud_vswitch" "vsw" { 

  vpc_id            = "alicloud_vpc.vpc.id" 

  cidr_block        = "172.16.0.0/21" 

  availability_zone = "ap-southeast-1a"  
  depends_on = [alicloud_vpc.vpc]
} 

# this is to create SGroup  

resource "alicloud_security_group" "default" { 

  name = "test" 

  vpc_id = alicloud_vpc.vpc.id 

} 

# This is to create the ECS Instance 

resource "alicloud_instance" "instance" { 

  availability_zone = "ap-southeast-1a" 

  security_groups = alicloud_security_group.default. *.id 

  instance_type        = "ecs.n2.small" 

  system_disk_category = "cloud_efficiency" 

  image_id             = "ubuntu_18_04_64_20G_alibase_20190624.vhd" 

  instance_name        = "test_foo" 

  vswitch_id = alicloud_vswitch.vsw.id 

  internet_max_bandwidth_out = 10 

} 

# This is to create a simple rule to SG 

resource "alicloud_security_group_rule" "allow_all_tcp" { 

  type              = "ingress" 

  ip_protocol       = "tcp" 

  nic_type          = "intranet" 

  policy            = "accept" 

  port_range        = "1/65535" 

  priority          = 1 

  security_group_id = alicloud_security_group.default.id 

  cidr_ip           = "0.0.0.0/0" 

} 

#This is to create SLB  

resource "alicloud_slb" "instance" { 

  name                 = "jawn-slb-demo" 

  address_type = "internet" 

  internet_charge_type = "paybybandwidth" 

  bandwidth            = 25 

  specification = "slb.s1.small" 

} 

# This is to create listener for front and backend, we use ssh and http as example 

resource "alicloud_slb_listener" "tcp" { 

  load_balancer_id          = alicloud_slb.instance.id 

  backend_port              = "22" 

  frontend_port             = "22" 

  protocol                  = "tcp" 

  bandwidth                 = "5" 

  health_check_type         = "tcp" 

  persistence_timeout       = 3600 

  healthy_threshold         = 8 

  unhealthy_threshold       = 8 

  health_check_timeout      = 8 

  health_check_interval     = 5 

  health_check_http_code    = "http_2xx" 

  health_check_connect_port = 20 

  health_check_uri          = "/console" 

  established_timeout       = 600 

} 

resource "alicloud_slb_listener" "http" { 

  load_balancer_id          = alicloud_slb.instance.id 

  backend_port              = 80 

  frontend_port             = 80 

  protocol                  = "http" 

  sticky_session            = "on" 

  sticky_session_type       = "insert" 

  cookie                    = "testslblistenercookie" 

  cookie_timeout            = 86400 

  health_check              = "on" 

  health_check_uri          = "/cons" 

  health_check_connect_port = 20 

  healthy_threshold         = 8 

  unhealthy_threshold       = 8 

  health_check_timeout      = 8 

  health_check_interval     = 5 

  health_check_http_code    = "http_2xx,http_3xx" 

  bandwidth                 = 5 

  request_timeout           = 80 

  idle_timeout              = 30 

} 
