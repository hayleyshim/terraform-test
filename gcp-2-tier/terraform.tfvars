project_name = "vm-test-341412"
name          = "vm-test" #추가
region = "us-west2"
zone = "us-west2-a"
bucket_name = "tf_backend_gcp_banuka_jana_jayarathna_k8s"
prefix = "terraform/gcp/boilerplate"
token_path = "./token.json"
storage_class = "REGIONAL"

##################webserver 추가#########################

backend-port  = "80" #추가
frontend-port = "80" #추가