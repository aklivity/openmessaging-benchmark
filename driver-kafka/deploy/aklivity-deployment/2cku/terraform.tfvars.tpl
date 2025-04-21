region          = "us-east-1"
ami             = "ami-084568db4383264d4"
profile         = "default"
keypair_id      = "akram-msk-proxy-us-east-1"
subnet_cidrs    = ["15.0.0.0/20", "15.0.16.0/20", "15.0.32.0/20"]
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
  "kafka"      = 6
  "controller" = 3
  "prometheus" = 1
}

gp3_size_gb       = 500
gp3_iops          = 3000
gp3_throughput_mb = 125
