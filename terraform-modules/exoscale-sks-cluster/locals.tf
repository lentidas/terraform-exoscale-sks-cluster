locals {
  # Decode the YAML kubeconfig file into a structured value in order to generate separate outputs for each of 
  # its fields.
  kubeconfig = yamldecode(resource.exoscale_sks_kubeconfig.this.kubeconfig)
}
