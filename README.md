# terraform-exoscale-sks-cluster

A Terraform module to deploy a Kubernetes cluster on Exoscale using the Exoscale Kubernetes Service (SKS).

## TODO

- [x] Add `.gitignore` and `README.md`
- [ ] Create basic module
  - [x] Create SKS cluster
  - [x] Create SKS node pool
  - [x] Create security group
  - [ ] Create security rules
- [ ] Find a way to secure K8s API behind our firewall
- [ ] Write documentation
- [ ] Add pipeline to add documentation to this README.md
- [ ] Add pipeline to publish new release using the `semantic-release` tool
- [ ] Investigate if the use of Private Networks is useful
