region          = "us-east-1"
owner           = "akram-msk-proxy"
ami             = "ami-00a929b66ed6e0de6"
profile         = "default"
subnet_cidrs    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]

instance_types = {
  "zilla"      = "m5.xlarge"
  "kafka"      = "m5.xlarge"
  "controller" = "m5.xlarge"
  "client"     = "m5.xlarge"
  "prometheus" = "m5.xlarge"
}

num_instances = {
  "client"     = 6
  "zilla"      = 3
  "kafka"      = 6
  "controller" = 3
  "prometheus" = 1
}

zilla_rootfs_gb   = 50

gp3_size_gb       = 500
gp3_iops          = 3000
gp3_throughput_mb = 125
