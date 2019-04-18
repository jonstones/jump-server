# Jump Server Container - 

This is a container image that I use as a base image to work from.

## Whats in it?

The current base image is ubuntu:latest, and it has the following installed:

* AWS cli ( aws )
* Azure cli ( az )
* Google cloud cli ( gcloud )
* Kubernetes ( kubectl )
* Terraform
* Ansible
* Git

not doing:

* vagrant - too many dependency packages
